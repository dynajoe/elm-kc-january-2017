import React from 'react'
import { render } from 'react-dom'
import { createStore } from 'redux'
import { Provider } from 'react-redux'
import App from './containers/App'
import reducer from './reducers'

export function RunApp(dom_element) {
  const store = createStore(reducer)

  render(
    <Provider store={store}>
      <App />
    </Provider>,
    dom_element
  )
}
