module stupet::stupet {
    use std::string::{String,utf8};
    use sui::tx_context::{TxContext,sender};
    use sui::object::delete;
    use sui::url::{Self,Url};
    use sui::transfer::{public_transfer, transfer};
    use std::vector;
    use sui::object::{Self,ID,UID};
    use sui::dynamic_object_field as dof;
    use sui::clock::Clock;
    use sui::event::emit;
    use sui::package::{Self};


    //===========ERROR========

    const EmoldAlreadyExist:u64 = 0;
    const EmoldNotExist:u64 = 1;
    const EanuthorizeUser:u64 = 2;
    const EscoreNotEnough:u64 = 3;

    //===========CONST========
    const BASE_EXP: u64 = 1000;
    const LOW_LEVEL: u64 = 1;


    const Type_cap:u64 = 1;
    const Type_action:u64 = 2;
    const Type_item:u64 = 3;

//=== ========Struct========
    public struct User has key,store{    
        id: UID,
        total_score: u64,
        user_address: address
    }
    
   public struct Item has key,store{
        id: UID,
        name: String,
        url: Url,
        mold: String
    }

    public struct Pet has key, store {
        id: UID,
        name: String,
        level: u64,
        exp: u64,
        birthdate: u64,
        url: Url,
        attributes: vector<String>
    }

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

    public struct Event_userCreated has copy,drop{
        id: ID,
        user_address: address,
        total_score: u64
    }
//===========init==========
    fun init(ctx:&mut TxContext){
        let admin_cap = AdminCap{id:object::new(ctx)};
        transfer::transfer(admin_cap,sender(ctx));
    }

//==============user_functions==========
    public entry fun create_user(ctx:&mut TxContext){
        let user = User{
            id: object::new(ctx),
            total_score: 0,
            user_address: sender(ctx)
        };
        emit(Event_userCreated{
            id: object::id(&user),
            user_address: sender(ctx),
            total_score: 0
        });
        transfer::transfer(user,sender(ctx));
    }

    public fun add_score(user: &mut User,score:u64){
        user.total_score = user.total_score + score;
    }

//===========Item_functions==========
    public entry fun mint_item(user: &mut User,types: u64,ctx:&mut TxContext){
        
        if(types == 1){
        let item = Item{
            id: object::new(ctx),
            name: utf8(b"cap"),
            url: url::new_unsafe_from_bytes(b"https://example.com/item.jpg"),
            mold: utf8(b"cap"),
        };
            transfer::transfer(item,sender(ctx));
        }
        else if(types == 2){
            let item = Item{
                id: object::new(ctx),
                name: utf8(b"action"),
                url: url::new_unsafe_from_bytes(b"https://example.com/item.jpg"),
                mold: utf8(b"action"),
            };
            transfer::transfer(item,sender(ctx));
        }
        else{
             let item = Item{
                id: object::new(ctx),
                name: utf8(b"item"),
                url: url::new_unsafe_from_bytes(b"https://example.com/item.jpg"),
                mold: utf8(b"item"),
            };
            transfer::transfer(item,sender(ctx));
        }
        
    }

//===========pet_functions==========
    public fun uid_mut(pet: &mut Pet): &mut UID { &mut pet.id }

    public fun create_pet(name:String,clock:&Clock,ctx:&mut TxContext){
        let pet = Pet{
            id: object::new(ctx),
            name,
            level:1,
            birthdate: sui::clock::timestamp_ms(clock),
            attributes: vector[],
            exp:0,
            url: url::new_unsafe_from_bytes(b"https://example.com/pet.jpg")
        };

    emit(Event_petCreated{
        id: object::id(&pet),
        name,
        owner: sender(ctx),
        });

    transfer::transfer(pet,sender(ctx));
    }

//===========transfer==========
    public fun add_item_to_pet(pet:&mut Pet,item:Item){
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

    //sign in 
    public entry fun update_pet(pet:&mut Pet,ctx:&mut TxContext) {
        pet.level = pet.level + 2;
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








