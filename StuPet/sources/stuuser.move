module stupet::stuuser {

    use std::string::String;
    use sui::clock::Clock;
    use stupet::stupet::Pet;
    use stupet::stupet;

    //===========ERROR========

    const ENotEnoughPoints: u64 = 101;

    //===========CONST========
    const INIT_PIONTS: u64 = 1000;

    //===========STRUCT========
    public struct User has key, store {
        id: UID,
        pet: Option<&Pet>,
        points: u64,
        owner: address,
    }

    //===========FUNC========
    // create user
    public entry fun create_user(ctx: &mut TxContext) {
        let user = User {
            id: object::new(ctx),
            owner: ctx.sender(),
            points: 0,
            pet: option::none<&Pet>(),
        };
        transfer::public_transfer(user, ctx.sender());
    }

    // create pet
    public entry fun create_pet(user: &mut User, name: String, clock: &Clock, ctx: &mut TxContext) {
        let pet = stupet::create_pet(name, clock, ctx);
        user.pet = option::some(pet);
        user.points = INIT_PIONTS;
    }

    // add
    public entry fun add_points(points: u64, ctx: &mut TxContext) acquires User {
        //add points on User;
        let mut user = get_user(ctx.sender());
        user.points = user.points + points;
        //add exp on Pet;
        stupet::add_exp(stupet::get_pet(ctx.sender()), points);
    }

    // use
    public entry fun use_points(points: u64, ctx: &mut TxContext) acquires User {
        //use points on User;
        let mut user = get_user(ctx.sender());
        assert!(user.points >= points, ENotEnoughPoints);
        user.points = user.points - points;
        //add exp on Pet;
        stupet::add_exp(stupet::get_pet(ctx.sender()), points);
    }

    public fun get_user(address: address): &mut User acquires User {
        borrow_global_mut<User>(address)
    }
}