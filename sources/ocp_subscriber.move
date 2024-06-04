module 0x0::ocp_subscriber {
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
        let subscriber = Subscriber {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
            creator,
        };
        transfer::transfer(subscriber, sender);
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