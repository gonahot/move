module stupet::stupet {
    use std::string::{String, utf8};
    use sui::tx_context::{TxContext, sender};
    use sui::object::{Self, ID, UID};
    use sui::dynamic_object_field as dof;
    use sui::clock::Clock;

    //===========ERROR========

    const EmoldAlreadyExist: u64 = 201;
    const EmoldNotExist: u64 = 202;

    //===========CONST========
    const BASE_EXP: u64 = 1000;
    const LOW_LEVEL: u64 = 1;

    //===========STRUCT========

    public struct Item has key, store {
        id: UID,
        name: String,
        url: String,
        mold: String
    }

    public struct Pet has key, store {
        id: UID,
        name: String,
        level: u64,
        exp: u64,
        birthdate: u64,
        url: String,
        attributes: vector<String>
    }

    // public struct STUPET has drop{}

    //===========capibilities and dynamic==========

    public struct AdminCap has key, store {
        id: UID
    }

    public struct ItemKey has copy, store, drop { mold: String }

    //===========Event==========
    public struct Event_petCreated has copy, drop {
        id: ID,
        name: String,
        owner: address,
    }


    //===========init==========
    fun init(ctx: &mut TxContext) {
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, sender(ctx));
    }

    //===========Item_functions==========
    // public fun url ()
    // let vector_item = vector::new();

    // let [1,2,3,4,5] =
    // public fun mint_item(ctx:&mut TxContext,name:String,mold:String):Item{
    //     assert!(df::exists_with_type<MintCapKey, MintCap>(app, MintCapKey {}), ENotAuthorized);
    //     assert!(df::exists_with_type<MintCapKey, MintCap>(a)), EanuthorizeUser);
    //     url =
    //     let item = Item{
    //         id: object::new(ctx),
    //         name,
    //         url,
    //         mold
    //     };
    //     item

    // }

    public fun uid_mut(pet: &mut Pet): &mut UID { &mut pet.id }

    public fun add_item_to_pet(pet: &mut Pet, item: Item) {
        let uid_mut = uid_mut(pet);
        assert!(!dof::exists_(uid_mut, ItemKey { mold: item.mold }), EmoldAlreadyExist);
        dof::add(uid_mut, ItemKey { mold: item.mold }, item)
    }

    public fun remove_item_from_pet(pet: &mut Pet, mold: String): Item {
        let uid_mut = uid_mut(pet);
        assert!(!dof::exists_(uid_mut, ItemKey { mold }), EmoldNotExist);
        dof::remove(uid_mut, ItemKey { mold })
    }

    //===========pet_functions==========
    public fun create_pet(name: String, clock: &Clock, ctx: &mut TxContext): &mut Pet{
        let url = utf8(b"https://example.com/pet.jpg");
        let pet = Pet {
            id: object::new(ctx),
            name,
            level: LOW_LEVEL,
            exp: BASE_EXP,
            birthdate: sui::clock::timestamp_ms(clock),
            attributes: vector<String>[],
            url,
        };
        // event
        // emit(Event_petCreated{
        //     id: object::id(&pet),
        //     name,
        //     owner: sender(ctx),
        //     });
        transfer::transfer(pet, ctx.sender());
        &mut pet
    }

    public fun add_exp(pet: &mut Pet, exp: u64) {
        pet.exp = pet.exp + exp;
        pet.level = calc_level(pet.exp, LOW_LEVEL);
    }

    public fun calc_level(exp: u64, level: u64): u64 {
        let rem_exp = exp - level * BASE_EXP;
        if (rem_exp > 0) {
            calc_level(rem_exp, level + 1)
        } else {
            level
        }
    }

    //===========read_item==========
    public fun get_item_name(item: &Item): String {
        item.name
    }

    public fun get_mold(item: &Item): String {
        item.mold
    }

    //===========read_pet==========
    public fun get_pet(address: address): &mut Pet acquires Pet {
        borrow_global_mut<Pet>(address)
    }

    public fun get_name(pet: &Pet): String {
        pet.name
    }

    public fun get_level(pet: &Pet): u64 {
        pet.level
    }

    public fun get_birthdate(pet: &Pet): u64 {
        pet.birthdate
    }

    public fun get_url(pet: &Pet): String {
        pet.url
    }

    public fun get_attributes(pet: &Pet): vector<String> {
        pet.attributes
    }
}








