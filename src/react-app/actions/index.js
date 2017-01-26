import * as types from '../constants/ActionTypes'
import * as Axios from 'axios'

export const listTodos = () => {
   return (dispatch) => {
      Axios.get('/todos')
      .then(response => {
         dispatch({
            type: types.TODOS_FETCHED,
            todos: response.data,
         })
      })
   }
}

export const addTodo = text => {
   return (dispatch) => {
      Axios.post('/todos', {
         text,
      })
      .then(response => {
         dispatch({
            type: types.ADD_TODO,
            todo: response.data,
         })
      })
   }
}

export const deleteTodo = todo => {
   return (dispatch) => {
      Axios.delete('/todos/' + todo.todo_id)
      .then(response => {
         dispatch({
            type: types.DELETE_TODO,
            todo,
         })
      })
   }
}

export const editTodo = (todo, text) => {
   return (dispatch) => {
      Axios.put('/todos', {
         todo_id: todo.todo_id,
         text,
         completed: todo.completed,
      })
      .then(response => {
         dispatch({
            type: types.EDIT_TODO,
            todo: response.data,
         })
      })
   }
}

export const toggleTodoComplete = todo => {
   return (dispatch) => {
      Axios.put('/todos', {
         todo_id: todo.todo_id,
         text: todo.text,
         completed: !todo.completed,
      })
      .then(response => {
         dispatch({
            type: types.COMPLETE_TODO,
            todo: response.data,
         })
      })
   }
}

export const completeAll = (todos) => {
   return (dispatch) => {
      const areAllMarked = todos.every(todo => todo.completed)

      Promise.all(todos.map(todo => {
         return Axios.put('/todos', {
            todo_id: todo.todo_id,
            text: todo.text,
            completed: !areAllMarked,
         })
      }))
      .then(completed_todos => {
         dispatch({
            type: types.COMPLETE_ALL,
            todos: completed_todos.map(r => r.data),
         })
      })
   }
}

export const clearCompleted = (todos) => {
   return (dispatch) => {
      const to_delete = todos.filter(t => t.completed)
      to_delete.forEach(t => deleteTodo(t)(dispatch))
   }
}
