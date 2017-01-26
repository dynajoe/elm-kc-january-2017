import React, { Component, PropTypes } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Header from '../components/Header'
import MainSection from '../components/MainSection'
import * as TodoActions from '../actions'

class App extends Component {
   componentDidMount() {
      this.props.actions.listTodos()
   }

   render() {
      return (<div className="todomvc-wrapper">
         <section className="todoapp">
            <Header addTodo={this.props.actions.addTodo} />
            <MainSection todos={this.props.todos} actions={this.props.actions} />
         </section>
      </div>)
   }
}

App.propTypes = {
  todos: PropTypes.array.isRequired,
  actions: PropTypes.object.isRequired
}

const mapStateToProps = state => ({
  todos: state.todos
})

const mapDispatchToProps = dispatch => ({
    actions: bindActionCreators(TodoActions, dispatch)
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App)
