module stupet::stupet {
    use std::string::{String,utf8};
    use sui::tx_context::{TxContext,sender};
    use sui::object::delete;
   
    use sui::transfer::{share_object, transfer};
    use std::vector;
    use sui::object::{Self,ID,UID};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::clock::Clock;
    use sui::event::emit;
    use sui::package::{Self};
    use sui::display;

//===========ERROR========

    const EmoldAlreadyExist:u64 = 0;
    const EmoldNotExist:u64 = 1;
    const EanuthorizeUser:u64 = 2;

//===========Struct========

    public struct User has key,store{
        id:UID,
        name:String,
        pet:Pet,
        total_score:u64
    }
    
    public struct Item has key,store{
        id: UID,
        name: String,
        url: String,
        mold: String
    }

    public struct Pet has key,store{
        id: UID,
        name: String,
        grade_level: u64,
        birthdate: u64,
        url: String,
        attributes: vector<String>
    }

    // public struct STUPET has drop{}

//===========capibilities and dynamic==========

    public struct AdminCap has key,store{
        id: UID
    }
    public struct ItemKey has copy, store, drop { mold: String }

//===========Event==========
     public struct Event_petCreated has copy,drop{
        id: ID,
        name: String,
        owner: address,
    }



//===========init==========
    fun init(ctx:&mut TxContext){
        let admin_cap = AdminCap{id:object::new(ctx)};
        transfer::transfer(admin_cap,sender(ctx));
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
    
    public fun add_item_to_pet(pet:&mut Pet,item:Item){
        let uid_mut = uid_mut(pet);
        assert!(!dof::exists_(uid_mut, ItemKey{ mold: item.mold }), EmoldAlreadyExist);
        dof::add(uid_mut, ItemKey{ mold: item.mold }, item)
    }

    public fun remove_item_from_pet(pet:&mut Pet,mold:String):Item{
        let uid_mut = uid_mut(pet);
        assert!(!dof::exists_(uid_mut, ItemKey {mold}), EmoldNotExist);
        dof::remove(uid_mut,ItemKey { mold })
    }

//===========pet_functions==========
    public fun create_pet(name:String,clock:&Clock,ctx:&mut TxContext){
        let url = utf8(b"https://example.com/pet.jpg");
        let id = object::new(ctx);
        let pet = Pet{
            id: id,
            name,
            grade_level: 1,
            birthdate: sui::clock::timestamp_ms(clock),
            attributes: vector<String>[],
            url,
        };

    emit(Event_petCreated{
        id: object::id(&pet),
        name,
        owner: sender(ctx),
        });

    transfer::transfer(pet,sender(ctx));
    
    }

//===========read_item==========
    public fun read_item_name(item: &Item) :String {
        item.name 
    }
    public fun read_mold(item: &Item) :String {
        item.mold 
    }

//===========read_pet==========
    public fun read_name(pet: &Pet) :String {
        pet.name 
    }
    public fun read_grade_level(pet: &Pet) :u64 {
        pet.grade_level 
    }
    public fun read_birthdate(pet: &Pet) :u64 {
        pet.birthdate 
    }
    public fun read_url(pet: &Pet) :String {
        pet.url 
    }
    public fun read_attributes(pet: &Pet) :vector<String> {
        pet.attributes 
    }
}
    
    
    



    

   