import { ADD_TODO, TODOS_FETCHED, DELETE_TODO, EDIT_TODO, COMPLETE_TODO, COMPLETE_ALL, CLEAR_COMPLETED } from '../constants/ActionTypes'

const initialState = []

export default function todos(state = initialState, action) {
  switch (action.type) {
    case TODOS_FETCHED:
      return action.todos

    case ADD_TODO:
      return [
        action.todo,
        ...state
      ]

    case DELETE_TODO:
      return state.filter(todo =>
        // Accidentally had action.todo_id
        todo.todo_id !== action.todo.todo_id
      )

    case EDIT_TODO:
      return state.map(todo =>
        todo.todo_id === action.todo.todo_id ?
          action.todo :
          todo
      )

    case COMPLETE_TODO:
      return state.map(todo =>
        todo.todo_id === action.todo.todo_id ?
          action.todo :
          todo
      )

    case COMPLETE_ALL:
      // const areAllMarked = state.every(todo => todo.completed)
      return action.todos

    case CLEAR_COMPLETED:
      return state.filter(todo => todo.completed === false)

    default:
      return state
  }
}
