/// Module: pet
module pet::pet {
    use std::string::String;
    use std::vector;
    use sui::bcs;
    use sui::hash::blake2b256 as hash;
    use sui::tx_context::{sender, TxContext};
    use sui::object::{Self, ID, UID};
    use sui::vec_set::{Self, VecSet};
    use sui::dynamic_field as df;
    use sui::clock::Clock;
    use sui::event::emit;
    use sui::transfer;
    use sui::package;

    /// Trying to perform an action when not authorized.
    const ENotAuthorized: u64 = 0;

    // ======== Types =========

    /// The `Pet` type - the main type of the `Pet` package which contains all common attributes.
    public struct Pet has key, store {
        id: UID,
        name: String,
        score: u64,
        birthdate: u64,
        attributes: vector<String>,
    }

    /// Capability granting mint permission.
    public struct AppCap has store, drop {
        app_name: String,
        cohort: u32,
        cohort_name: String,
        time_limit: u64,
        minting_limit: u64,
        minting_counter: u64,
        allowed_country_codes: VecSet<String>,
    }

    /// Admin Capability which allows third-party applications.
    public struct AdminCap has key, store { id: UID }

    /// Custom key under which the app cap is attached.
    public struct AppKey has copy, store, drop {}

    /// OTW to create the `Publisher`.
    public struct PET has drop {}

    //------- Events ---------------

    /// Event. When a new Pet is born.
    public struct PetMinted has copy, drop {
        id: ID,
        app_name: String,
        score: u64,
        attributes: vector<String>,
        birthdate: u64,
        created_by: address,
    }

    /// Module initializer. Uses One Time Witness to create Publisher and transfer it to sender.
    fun init(otw: PET, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
        transfer::transfer(AdminCap { id: object::new(ctx) }, sender(ctx));
    }

    /// Mint a new Pet. Can only be performed by an authorized application.
    public fun mint(
        app: &mut UID,
        name: String,
        score: u64,
        attributes: vector<String>,
        clock: &Clock,
        ctx: &mut TxContext
    ): Pet {
        assert!(is_authorized(app), ENotAuthorized);

        let app_cap = app_cap_mut(app);

        let id = object::new(ctx);
        let birthdate = sui::clock::timestamp_ms(clock);

        emit(PetMinted {
            id: object::uid_to_inner(&id),
            app_name: app_cap.app_name,
            score,
            attributes,
            birthdate,
            created_by: sender(ctx)
        });

        Pet {
            id,
            name,
            score,
            birthdate,
            attributes,
        }
    }

    /// Unpack the `Pet` object and return UID for dynamic fields processing.
    public fun burn(app: &mut UID, pet: Pet): UID {
        assert!(is_authorized(app), ENotAuthorized);
        let Pet {
            id,
            name: _,
            score: _,
            birthdate: _,
            attributes: _
        } = pet;
        id
    }

    // === Authorization ===

    /// Attach an `AppCap` under an `AppKey` to grant an application access.
    public fun authorize_app(
        _: &AdminCap,
        app: &mut UID,
        app_name: String,
        cohort_num: u32,
        cohort_name: String,
        time_limit: u64,
        minting_limit: u64,
        allowed_country_codes: vector<String>,
    ) {
        df::add(app, AppKey {},
            AppCap {
                cohort: cohort_num,
                app_name,
                cohort_name,
                time_limit,
                minting_limit,
                minting_counter: 0,
                allowed_country_codes: vec_to_set(allowed_country_codes)
            }
        )
    }

    /// Detach the `AppCap` from the application to revoke access.
    public fun revoke_auth(_: &AdminCap, app: &mut UID) {
        let AppCap {
            app_name: _,
            cohort: _,
            cohort_name: _,
            time_limit: _,
            minting_limit: _,
            minting_counter: _,
            allowed_country_codes: _
        } = df::remove(app, AppKey {});
    }

    /// Check whether an Application has permission to mint or burn a specific Pet.
    public fun is_authorized(app: &UID): bool {
        df::exists_<AppKey>(app, AppKey {})
    }

    // === Pet Fields ===

    /// Accessor for the `attributes` field of a `Pet`.
    public fun attributes(self: &Pet): &vector<String> { &self.attributes }

    // === Internal ===

    /// Returns the `AppCap` that provides information about the application.
    fun app_cap_mut(app: &mut UID): &mut AppCap {
        df::borrow_mut<AppKey, AppCap>(app, AppKey {})
    }

    /// Internal: turn a `vector` into a `VecSet`.
    fun vec_to_set<T: store + copy + drop>(v: vector<T>): VecSet<T> {
        let mut vec_set = vec_set::empty();
        let mut v_copy = v;
        while (vector::length(&v) > 0) {
            vec_set::insert(&mut vec_set, vector::pop_back(&mut v_copy));
        };
        vec_set
    }

    // === Test functions ===

    #[test_only]
    public fun mint_for_testing(ctx: &mut TxContext): Pet {
        let id = object::new(ctx);
        Pet {
            id,
            name: String::from_utf8(b"Test Pet"),
            score: 0,
            birthdate: 0,
            attributes: vector[],
        }
    }

    #[test_only]
    public fun burn_for_testing(pet: Pet) {
        let Pet {
            id,
            name: _,
            score: _,
            birthdate: _,
            attributes: _,
        } = pet;
        object::delete(id)
    }

    #[test_only]
    public fun test_new_admin_cap(ctx: &mut TxContext): AdminCap {
        AdminCap { id: object::new(ctx) }
    }

    #[test_only]
    public fun test_destroy_admin_cap(cap: AdminCap) {
        let AdminCap { id } = cap;
        object::delete(id)
    }
}