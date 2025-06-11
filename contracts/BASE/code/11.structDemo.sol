// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.0 <0.9.0;

contract Structs {
    struct Todo {
        string text;
        bool completed;
    }
    // 结构体数组
  
    Todo[] public todos;

    // 初始化结构的3种方法
    function create(string calldata _text) public {
        // 1.像函数一样调用它
        todos.push(Todo(_text, false));
        // 2. 键值对
        todos.push(Todo({text: _text, completed: false}));
        // 3.初始化一个空结构，然后更新它
        Todo memory todo;
        todo.text = _text;
        todos.push(todo);// completed 没有定义,默认为 false
    }
    //通过索引获取结构体数组中一个元素,并更新内部的属性
    function update(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}