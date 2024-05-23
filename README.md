# Inventory Management System

This iOS based application is implemented to help the users add Items to their Inventory, add Orders that contains varying Items with varying quantities. Once the user requests any amount of Orders, the required Items will get deducted from the Inventory. The user can also check the status of the stocks left in their Inventory.

Delving deep into the Architecture of the project:
# MVVM (Model View View-Model) Architecture

MVVM (Model-View-ViewModel) is a software architectural pattern that facilitates a clear separation of concerns within applications, particularly in the context of GUIs. It divides the application into three interconnected components: the Model, which represents the data and business logic; the View, which is the UI and its structure; and the ViewModel, which acts as an intermediary that holds the presentation logic and the state of the UI. The View-Model binds the data from the Model to the View, ensuring that any changes in the data are automatically reflected in the UI, and vice versa, through data binding and command patterns. This architecture promotes modularity, testability, and maintainability by decoupling the UI from the business logic.
