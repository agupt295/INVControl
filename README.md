# Inventory Management System

This iOS based application is implemented to help the users add Items to their Inventory, add Orders that contains varying Items with varying quantities. Once the user requests any amount of Orders, the required Items will get deducted from the Inventory. The user can also check the status of the stocks left in their Inventory.

[Delving deep into the Architecture of the project]:
# Use-Case Diagram

It is a visual representation of the functional requirements of a system, illustrating the interactions between users (actors) and the system itself. It identifies the various use cases, which are specific functionalities or services provided by the system, and shows how these use cases are related to the actors who initiate them.
(include) : To represent the functionality of the use case
(extend) : To represent optional or conditional behavior that extends the base use case

<img width="978" alt="Screenshot 2024-05-23 at 12 17 33 AM" src="https://github.com/agupt295/INVControl/assets/118144312/884d8ecb-d5d8-45ba-aa3f-6d3b6f1ae306">


# MVVM (Model View View-Model) Architecture

MVVM is a software architectural pattern that facilitates a clear separation of concerns within applications, particularly in the context of GUIs. It divides the application into three interconnected components: the Model, which represents the data and business logic; the View, which is the UI and its structure; and the ViewModel, which acts as an intermediary that holds the presentation logic and the state of the UI. The View-Model binds the data from the Model to the View, ensuring that any changes in the data are automatically reflected in the UI, and vice versa, through data binding and command patterns. This architecture promotes modularity, testability, and maintainability by decoupling the UI from the business logic.

<img width="980" alt="Screenshot 2024-05-23 at 1 01 31 AM" src="https://github.com/agupt295/INVControl/assets/118144312/8eb9bb40-a060-48a4-bba7-ea883350bf9d">
