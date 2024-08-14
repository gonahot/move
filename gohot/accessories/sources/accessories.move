/*
/// Module: accessories
module accessories::accessories {

}
*/
module accessories::accessories {
    use std::string::String;

    use sui::tx_context::TxContext;
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::package::{Self};
    use pet::pet::{Self, AdminCap, Pet};

    /// Trying to remove an accessory that doesn't exist.
    const EAccessoryaccessories_TypeDoesNotExist: u64 = 0;
    /// Trying to add an accessory that already exists.
    const EAccessoryaccessories_TypeAlreadyExists: u64 = 1;
    /// An application is not authorized to mint.
    const ENotAuthorized: u64 = 2;

    /// OTW to create the `Publisher`.
    public struct ACCESSORIES has drop {}

    /// A Pet Accessory, that is being purchased from the `AccessoriesStore`.
    public struct Accessory has key, store {
        id: UID,
        name: String,
        accessories_type: String,
        url:String,
    }

    /// This public struct represents where the accessory is going to be mounted
    public struct AccessoryKey has copy, store, drop { accessories_type: String }

    /// The key for the `MintCap` store.
    public struct MintCapKey has copy, store, drop {}

    /// A capability allowing to mint new accessories. Later can be replaced
    /// by a better better solution. Not used anywhere in accessories_type signatures.
    public struct MintCap has store {}

    /// Module initializer. Uses One Time Witness to create Publisher and transfer it to sender
    fun init(otw: ACCESSORIES, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    /// Mint a new Accessory; can only be called by authorized applications.
    public fun mint(app: &mut UID, name: String, accessories_type: String,url:String, ctx: &mut TxContext): Accessory {
        assert!(df::exists_with_accessories_type<MintCapKey, MintCap>(app, MintCapKey {}), ENotAuthorized);
        Accessory {
            id: object::new(ctx),
            name,
            accessories_type,
            url,
        }
    }

    /// Add accessory to the Pet. Stores the accessory under the `accessories_type` key
    /// making it impossible to wear two accessories of the same accessories_type.
    public fun add<T> (sf: &mut Pet<T>, accessory: Accessory) {
        let uid_mut = pet::uid_mut(sf);
        assert!(!dof::exists_(uid_mut, AccessoryKey{ accessories_type: accessory.accessories_type }), EAccessoryTypeAlreadyExists);
        dof::add(uid_mut, AccessoryKey{ accessories_type: accessory.accessories_type }, accessory)
    }

    /// Remove accessory from the Pet. Removes the accessory with the given
    /// `accessories_type`. Aborts if the accessory is not found.
    public fun remove<T> (sf: &mut Pet<T>, accessories_type: String): Accessory {
        let uid_mut = pet::uid_mut(sf);
        assert!(dof::exists_(uid_mut, AccessoryKey { accessories_type }), EAccessoryaccessories_TypeDoesNotExist);
        dof::remove(uid_mut, AccessoryKey { accessories_type })
    }

    // === Protected Functions ===

    /// Authorize an application to mint new accessories.
    public fun authorize_app(_: &AdminCap, app: &mut UID) {
        df::add(app, MintCapKey {}, MintCap {});
    }

    /// Deauthorize an application to mint new accessories.
    public fun deauthorize_app(_: &AdminCap, app: &mut UID) {
        let MintCap {} = df::remove(app, MintCapKey {});
    }

    // === Reads ===

    /// Accessor for the `name` field of the `Accessory`.
    public fun name(accessory: &Accessory): String {
        accessory.name
    }

    /// Accessor for the `accessories_type` field of the `Accessory`.
    public fun accessories_type(accessory: &Accessory): String {
        accessory.accessories_type
    }

    // === Functions for Testing ===
    #[test_only]
    public fun test_burn(accessory: Accessory) {
        let Accessory { id, name: _, accessories_type: _ ,url: _ } = accessory;
        object::delete(id);
    }
}