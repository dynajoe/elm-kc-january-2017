const Express = require('express')
const App = Express()
const Server = require('http').createServer(App)
const Path = require('path')
const Static = require('./static')
const BodyParser = require('body-parser')

Static.initialize(App)

App.use(BodyParser.json())

Server.listen(4000, () => {
   console.log('Server listening on port 4000')
})

let todos = []

App.post('/todos', (req, res) => {
   console.log('Creating todo', req.body)

   const new_todo = {
      todo_id: Date.now(),
      text: req.body.text,
      completed: false,
      created_on: new Date(),
   }

   console.log('New todo', JSON.stringify(new_todo, null, 2))

   todos = todos.concat(new_todo)

   res.json(200, new_todo)
})

App.get('/todos', (req, res) => {
   console.log('Fetching todos', JSON.stringify(todos, null, 2))

   res.json(200, todos)

})

App.put('/todos', (req, res) => {
   console.log('Updating todo', req.body)

   todos = todos.map(t => {
      if (t.todo_id === req.body.todo_id) {
         return {
            todo_id: t.todo_id,
            text: req.body.text,
            completed: req.body.completed,
            created_on: t.created_on,
         }
      }

      return t
   })

   res.json(200, todos.find(t => t.todo_id === req.body.todo_id))
})

App.delete('/todos', (req, res) => {
   console.log('Deleting todo', req.body.todo_id)

   todos = todos.filter(t => t.todo_id !== req.body.todo_id)
   res.json(200, todos)
})
