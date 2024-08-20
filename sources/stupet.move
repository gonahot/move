module stupet::stupet {
    use std::string::{String, utf8};
    use sui::url::{Self, Url};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::clock::Clock;
    use sui::event::emit;
    use sui::tx_context::{TxContext,sender};

//===========ERROR========

    const EmoldAlreadyExist:u64 = 0;
    const EmoldNotExist:u64 = 1;
    const EanuthorizeUser:u64 = 2;
    const EscoreNotEnough:u64 = 3;

//===========Const========
    const Type_cap:u64 = 1;
    const Type_action:u64 = 2;
    const Type_item:u64 = 3;

//=== ========Struct========
    public struct User has key, store {    
        id: UID,
        total_score: u64,
        user_address: address
    }
    
   public struct Item has key, store {
        id: UID,
        name: String,
        url: Url,
        mold: String
    }

    public struct Pet has key, store{
        id: UID,
        name: String,
        grade_level: u64,
        birthdate: u64,
        url: Url,
        attributes: vector<String>
    }

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

    public struct Event_userCreated has copy,drop{
        id: ID,
        user_address: address,
        total_score: u64
    }
//===========init==========
    fun init(ctx:&mut TxContext){
       transfer::transfer(AdminCap{id: object::new(ctx)}, ctx.sender());
    }

//==============user_functions==========
    public entry fun create_user(ctx:&mut TxContext) {
        let user = User{
            id: object::new(ctx),
            total_score: 0,
            user_address: ctx.sender()
        };
        emit(Event_userCreated{
            id: object::id(&user),
            user_address: ctx.sender(),
            total_score: 0
        });
        transfer::transfer(user,ctx.sender());
    }

    public fun add_score(user: &mut User, score:u64){
        user.total_score = user.total_score + score;
    }

//===========Item_functions==========
    public entry fun mint_item(user: &mut User,types: u64,ctx:&mut TxContext){
        assert!(user.total_score >= 10,EscoreNotEnough);
        if(types == 1){
        let item = Item{
            id: object::new(ctx),
            name: utf8(b"cap"),
            url: url::new_unsafe_from_bytes(b"https://example.com/item.jpg"),
            mold: utf8(b"cap"),
        };
            user.total_score = user.total_score - 10;
            transfer::transfer(item,sender(ctx));
        }
        else if(types == 2){
            let item = Item{
                id: object::new(ctx),
                name: utf8(b"action"),
                url: url::new_unsafe_from_bytes(b"https://example.com/item.jpg"),
                mold: utf8(b"action"),
            };
            user.total_score = user.total_score - 10;
            transfer::transfer(item,sender(ctx));
        }
        else{
             let item = Item{
                id: object::new(ctx),
                name: utf8(b"item"),
                url: url::new_unsafe_from_bytes(b"https://example.com/item.jpg"),
                mold: utf8(b"item"),
            };
            user.total_score = user.total_score - 10;
            transfer::transfer(item,sender(ctx));
        }
        
    }

    //===========pet_functions==========
    public fun uid_mut(pet: &mut Pet) : &mut UID { &mut pet.id }

    public entry fun create_pet(name:String, clock:&Clock, ctx:&mut TxContext) {
    
        let pet = Pet{
            id: object::new(ctx),
            name,
            grade_level:1,
            birthdate: sui::clock::timestamp_ms(clock),
            attributes: vector[],
            url: url::new_unsafe_from_bytes(b"https://static-1317507328.cos.ap-nanjing.myqcloud.com/other/4a55c3a273541901ee3c82e91ddb3f2f.gif")
        };

        emit(Event_petCreated{
            id: object::id(&pet),
            name,
            owner: ctx.sender(),
            });

        transfer::transfer(pet,ctx.sender());
    }

    //===========transfer==========

    public fun add_item_to_pet(pet:&mut Pet, item:Item){
        let uid_mut = uid_mut(pet);
        assert!(!dof::exists_(uid_mut, ItemKey{ mold: item.mold }), EmoldAlreadyExist);
        dof::add(uid_mut, ItemKey{ mold: item.mold }, item)
    }

    public fun remove_item_from_pet(pet:&mut Pet,mold:String) : Item {
        let uid_mut = uid_mut(pet);
        assert!(!dof::exists_(uid_mut, ItemKey {mold}), EmoldNotExist);
        dof::remove(uid_mut,ItemKey { mold })
    }

    //sign in +5 score and gradelevel
    public entry fun update_pet(pet:&mut Pet, ctx:&mut TxContext) {
        pet.grade_level = pet.grade_level + 2;
    }

    //===========read_item==========
    public fun read_item_name(item: &Item) : String {
        item.name 
    }
    public fun read_mold(item: &Item) : String {
        item.mold 
    }

    //===========read_pet==========
    public fun read_name(pet: &Pet) : String {
        pet.name 
    }
    public fun read_grade_level(pet: &Pet) : u64 {
        pet.grade_level 
    }
    public fun read_birthdate(pet: &Pet) : u64 {
        pet.birthdate 
    }
    
    public fun read_attributes(pet: &Pet) : vector<String> {
        pet.attributes 
    }
}
    