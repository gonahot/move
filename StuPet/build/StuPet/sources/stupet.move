module stupet::stupet {
    use std::string::String;
    use sui::tx_context::TxContext;
    use sui::object::delete;
    use sui::transfer::{share_object, transfer};
    use sui::tx_context::sender;
    use std::vector;
    use sui::object::UID;
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;

//===========ERROR========

    const EmoldAlreadyExist:u64 = 0;
    const EmoldNotExist:u64 = 1;

//===========Struct========

    public struct User has key,store{
        id:UID,
        name:String,
        pet:Pet,
        total_score:u64,
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
        attributes: vector<String>,
        owner: address
    }

//===========capibilities and dynamic==========

    public struct AdminCap has key,store{
        id: UID
    }

    public struct MintCapKey has copy, store, drop {}

    /// The key for the `MintCap` store.
    public struct MintCap has store{}
    
    public struct ItemKey has copy, store, drop { mold: String }

//===========Event==========
    // publicstruct Event_petCreated{id:ID}



//===========init==========
    fun init(ctx:&mut TxContext){
        let admin_cap = AdminCap{id:object::new(ctx)};
        transfer::transfer(admin_cap,sender(ctx));

    }

//===========Item_functions==========
    
    public fun mint_item(ctx:&mut TxContext,name:String,url:String,mold:String):Item{
        let item = Item{
            id: object::new(ctx),
            name,
            url,
            mold
        };
        item
    }   
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

//===========Accesss_control==========
    /// Authorize an user to mint new accessories.
    public fun authorize_user(_: &AdminCap, user: &mut UID) {
        df::add(user, MintCapKey {}, MintCap {});
    }

    /// Deauthorize an userto mint new accessories.
    public fun deauthorize_user(_: &AdminCap, user: &mut UID) {
        let MintCap {} = df::remove(user, MintCapKey {});
    }


// //===========read_item==========
    public fun read_name(item: &Item) :String {
        item.name 
    }
    public fun read_url(item: &Item) :String {
        item.url 
    }
    public fun read_mold(item: &Item) :String {
        item.mold 
    }

// //===========read_pet==========
//     public fun read_name(pet: &Pet) :String {
//         pet.name 
//     }
//     public fun read_grade_level(pet: &Pet) :u64 {
//         pet.grade_level 
//     }
//     public fun read_birthdate(pet: &Pet) :u64 {
//         pet.birthdate 
//     }
//     public fun read_url(pet: &Pet) :String {
//         pet.url 
//     }
//     public fun read_attributes(pet: &Pet) :vector<String> {
//         pet.attributes 
//     }
//     public fun read_owner(pet: &Pet) :address {
//         pet.owner 
//     }
}
    
    
    



    

   