module stupet::stupet {
    use std::string::String;
    use sui::tx_context::TxContext;
    use sui::random::{Random, new_generator,generate_u8_in_range};
    use sui::object::delete;
    use sui::transfer::{share_object, transfer};
    use sui::tx_context::sender;
    use std::vector;
    use sui::object::UID;
    use sui::dynamic_object_field as dof;

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

    public struct AdminCap has key,store{
        id: UID
    }

    public struct ItemKey has copy, store, drop { mold: String }

//===========Event==========
    // publicstruct Event_petCreated{id:ID}



//===========init==========
    fun init(ctx:&mut TxContext){
        let admin_cap = AdminCap{id:object::new(ctx)};
        transfer::transfer(admin_cap,sender(ctx));

    }

//===========Item_functions==========
    
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




//===========read==========
    }
    
    
    



    

   