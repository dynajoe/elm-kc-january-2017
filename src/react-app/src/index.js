import React from 'react'
import { render } from 'react-dom'
import { createStore, applyMiddleware } from 'redux'
import { Provider } from 'react-redux'
import App from './containers/App'
import reducer from './reducers'
import thunk from 'redux-thunk'

export function RunApp(dom_element) {
  const store = createStore(reducer, {}, applyMiddleware(thunk))

  render(
    <Provider store={store}>
      <App />
    </Provider>,
    dom_element
  )
}
