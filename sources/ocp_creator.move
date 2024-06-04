module 0x0::ocp_creator {
    use std::string::String;
    use sui::event::emit;
    
    /// The `Creator` struct represents a creator in the OCP.
    /// It contains information about the creator, such as their name, URL, description, and avatar.
    public struct Creator has key, store {
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
        member_prices: vector<u64>,
    }

    public struct CreatorUpdatedEvent has copy, drop, store {
        old_creator_id: ID,
        new_creator_id: ID,
    }

    public struct PostCreatedEvent has copy, drop, store {
        post_id: ID,
        creator: address,
        access_level: u8,
    }

    /// The `Post` struct represents a post created by a creator in the OCP.
    /// It contains information about the post, such as its ID, creator ID, URL, and description.
    public struct Post has key, store {
        id: UID,
        creator: address,
        url: String,
        description: String,
        access_level: u8,
    }
    
    /// The `PostKey` struct represents a key that grants access to a specific post.
    /// It contains the ID of the key and the ID of the associated post.    
    public struct PostKey has key, store{
        id: UID,
        post_id: ID,
        access_level: u8,
        owner: address,
    }

    /// Mints a new creator and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `url` - The URL of the creator.
    /// * `description` - The description of the creator.
    /// * `avatar` - The avatar of the creator.
    /// * `ctx` - The transaction context.
    public entry fun mint_creator(
        url: String,
        description: String,
        avatar: String,
        member_prices: vector<u64>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = Creator {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
            member_prices,
        };
        transfer::transfer(nft, sender);
    }
      
    /// Updates the URL, description, and avatar of an existing creator.
    /// 
    /// # Arguments
    /// 
    /// * `creator` - A mutable reference to the `Creator` object to be updated.
    /// * `url` - The new URL of the creator.
    /// * `description` - The new description of the creator.
    /// * `avatar` - The new avatar of the creator.
    /// * `_` - The transaction context (unused).    
    public entry fun update_creator(
        creator: &mut Creator,
        url: String,
        description: String,
        avatar: String,
    ) {
        let old_creator_id = object::id(creator);
        creator.url = url;
        creator.description = description;
        creator.avatar = avatar;
        let new_creator_id = object::id(creator);
        let event = CreatorUpdatedEvent {
            old_creator_id,
            new_creator_id,
        };
        emit(event);
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
        creator: &Creator,
        url: String,
        description: String,
        access_level: u8,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let post = Post {
            id: object::new(ctx),
            creator: get_creator_name(creator),
            url,
            description,
            access_level,
        };
        let post_id = object::id(&post);
        transfer::transfer(post, sender);
        let event = PostCreatedEvent {
            post_id,
            creator: sender,
            access_level,
        };
        emit(event);
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
        access_level: u8,
        _: &TxContext
    ) {
        post.url = url;
        post.description = description;
        post.access_level = access_level;
    }

    /// Mints a new post key and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `post` - A reference to the `Post` object associated with the key.
    /// * `ctx` - The transaction context.
    public entry fun mint_post_key(
        post: &Post,
        access_level: u8,
        owner: address,
        ctx: &mut TxContext
    ) {
        let key = PostKey {
            id: object::new(ctx),
            post_id: object::id(post),
            access_level,
            owner,
        };
        transfer::transfer(key, owner);
    }

    public fun get_creator_name(creator: &Creator): address {
        creator.name
    }

    public fun get_member_prices(creator: &Creator): &vector<u64> {
        &creator.member_prices
    }

    /// Checks if a user has access to a specific post based on their address and a vector of `PostKey`s.
    /// 
    /// # Arguments
    /// 
    /// * `post` - A reference to the `Post` object.
    /// * `user` - The address of the user.
    /// * `keys` - A reference to a vector of `PostKey`s owned by the user.
    /// 
    /// # Returns
    /// 
    /// * `true` if the user has access to the post, `false` otherwise.
    public fun has_access(post: &Post, user: address, keys: &vector<PostKey>): bool {
        let required_access_level = post.access_level;
        if (required_access_level == 0) {
            return true
        };
        check_keys(post, user, keys, required_access_level)
    }

    /// Checks if a user has a `PostKey` that grants access to a specific post.
    /// 
    /// # Arguments
    /// 
    /// * `post` - A reference to the `Post` object.
    /// * `user` - The address of the user.
    /// * `keys` - A reference to a vector of `PostKey`s owned by the user.
    /// * `required_access_level` - The access level required to view the post.
    /// 
    /// # Returns
    /// 
    /// * `true` if the user has a `PostKey` that grants access to the post, `false` otherwise.
    fun check_keys(post: &Post, user: address, keys: &vector<PostKey>, required_access_level: u8): bool {
        let len = vector::length(keys);
        let mut i = 0;
        while (i < len) {
            let key = vector::borrow(keys, i);
            if (key.post_id == object::id(post) && key.owner == user && key.access_level >= required_access_level) {
                return true
            };
            i = i + 1;
        };
        false
    }

}