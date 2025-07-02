# Singleton

**Singleton** is a creational design pattern that lets you ensure that a class has only one instance, while providing a global access point to it.

> [!CAUTION]
> The **Singleton** pattern solves 2 problem at same time, violating the *Single Responsibility Principle*

1. **Ensures that a class has just a single instance.** But why would anyone want to control how many instances a class has? the most common reason is to control access to the shared resources, such as a **file** or a **database**.
2. **Provide a global access point to that instance.** 