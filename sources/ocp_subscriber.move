module 0x0::ocp_subscriber {
    use sui::tx_context;
    use sui::object;
    use sui::transfer;
    use std::string::String;

    /// The `Subscriber` struct represents a subscriber in the OCP.
    /// It contains information about the subscriber, such as their name, URL, description, avatar, and creator.
    public struct Subscriber has key, store{
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
        creator: address,
    }

    /// The `Post` struct represents a post created by a creator in the OCP.
    /// It contains information about the post, such as its ID, creator ID, URL, and description.
    public struct Post has key, store {
        id: UID,
        creator: ID,
        url: String,
        description: String,
    }
    
    /// The `PostKey` struct represents a key that grants access to a specific post.
    /// It contains the ID of the key and the ID of the associated post.    
    public struct PostKey has key, store{
        id: UID,
        post_id: ID,
    }

    /// Mints a new post and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `creator` - A reference to the `Creator` object associated with the post.
    /// * `url` - The URL of the post.
    /// * `description` - The description of the post.
    /// * `ctx` - The transaction context.
    public entry fun mint_post(
        creator: &0x0::ocp_creator::Creator,
        url: String,
        description: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = Post {
            id: object::new(ctx),
            creator: object::id(creator),
            url,
            description,
        };
        transfer::transfer(nft, sender);
    }

    /// Updates the URL and description of an existing post.
    /// 
    /// # Arguments
    /// 
    /// * `post` - A mutable reference to the `Post` object to be updated.
    /// * `url` - The new URL of the post.
    /// * `description` - The new description of the post.
    /// * `_` - The transaction context (unused).
    public entry fun update_post(
        post: &mut Post,
        url: String,
        description: String,
        _: &TxContext
    ) {
        post.url = url;
        post.description = description;
    }

    /// Mints a new post key and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `post` - A reference to the `Post` object associated with the key.
    /// * `ctx` - The transaction context.
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

    /// Checks if a post key grants access to a specific post.
    /// 
    /// # Arguments
    /// 
    /// * `post` - A reference to the `Post` object.
    /// * `key` - A reference to the `PostKey` object.
    /// 
    /// # Returns
    /// 
    /// * `bool` - `true` if the post key grants access to the post, `false` otherwise.
    public entry fun has_access(
        post: &Post,
        key: &PostKey,
    ):bool {
        object::id(post) == key.post_id
    }

    /// Mints a new subscriber and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `creator` - The address of the creator associated with the subscriber.
    /// * `url` - The URL of the subscriber.
    /// * `description` - The description of the subscriber.
    /// * `avatar` - The avatar of the subscriber.
    /// * `ctx` - The transaction context.
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

    /// Updates the URL, description, and avatar of an existing subscriber.
    /// 
    /// # Arguments
    /// 
    /// * `subscriber` - A mutable reference to the `Subscriber` object to be updated.
    /// * `url` - The new URL of the subscriber.
    /// * `description` - The new description of the subscriber.
    /// * `avatar` - The new avatar of the subscriber.
    /// * `_` - The transaction context (unused).    
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