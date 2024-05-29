module 0x0::ocp_subscriber {
    use sui::tx_context;
    use sui::object;
    use sui::transfer;
    use std::string::String;


    public struct Subscriber has key, store{
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
        creator: address,
    }

    public struct Post has key, store {
        id: UID,
        creator_id: ID,
        url: String,
        description: String,
    }
    
    public struct PostKey has key, store{
        id: UID,
        post_id: ID,
    }

    public entry fun mint_post(
        creator: &0x0::ocp_creator::Creator,
        url: String,
        description: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = Post {
            id: object::new(ctx),
            creator_id: object::id(creator),
            url,
            description,
        };
        transfer::transfer(nft, sender);
    }

    public entry fun update_post(
        post: &mut Post,
        url: String,
        description: String,
        _: &TxContext
    ) {
        post.url = url;
        post.description = description;
    }

    public entry fun mint_post_key(
        post: &Post,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let key = PostKey {
            id: object::new(ctx),
            post_id: object::id(post),
        };
        transfer::transfer(key, sender);
    }

    public entry fun has_access(
        post: &Post,
        key: &PostKey,
    ):bool {
        object::id(post) == key.post_id
    }

    public entry fun mint_subscriber(
        creator: address,
        url: String,
        description: String,
        avatar: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        let nft = Subscriber {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
            creator,
        };
        transfer::transfer(nft, sender);
    }
    
    public entry fun update_subscriber(
        subscriber: &mut Subscriber,
        url: String,
        description: String,
        avatar: String,
        _: &TxContext
    ) {
        subscriber.url = url;
        subscriber.description = description;
        subscriber.avatar = avatar;
    }
}