#!/bin/bash

# TEST1="const express=require""('"express"');"

# echo $TEST1

read -p "Enter path you want to save project to.             
" PROJECTDIR

echo "

"

read -p "Enter name of your react project.      
" PROJECTNAME

PROJECTPATH+=$PROJECTDIR
PROJECTPATH+="/"
PROJECTPATH+=$PROJECTNAME
echo $PROJECTPATH

mkdir $PROJECTPATH

cd $PROJECTPATH

git init

echo node_modules/ > .gitignore

#create server folder
mkdir server
cd server
touch server.js

npm init -y

npm install express
npm install mongoose
npm install cors

#Create server.js file
echo "const express=require""('"express"');" > server.js
echo "const app = express();" >> server.js
echo "const cors = require('cors');" >> server.js
echo "app.use(cors());" >> server.js
echo "
const port=8000;
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
require('./config/mongoose.config.js'); 
require('./routes/users.routes.js')(app);
" >> server.js
echo "app.listen""(port, () => console.log("'`'Listening" "on" "port:" $""{port}"'`'") );" >> server.js

cd ..

npx create-react-app client

mkdir server/controllers
touch server/controllers/users.controller.js

#Create Controllers
echo "console.log("'"*******CONTROLLERS*******"'");" > server/controllers/users.controller.js
echo const" { response, request } = require('express');" >> server/controllers/users.controller.js
echo const" Users = require('../models/users.model');" >> server/controllers/users.controller.js

echo module.exports.getAllUsers" = (request, response) => {
    Users.find({})
        .then(users => {
            console.log(""'"Testing..."'"", users);
            response.json(users);
        })
        .catch(err => {
            console.log(err);
        });
};" >> server/controllers/users.controller.js

echo module.exports.getUser" = (request, response) => {
    console.log(""'"Params Test"'"", request.params);
    Users.findOne({_id: request.params.id})
        .then(user => {
            console.log(""'"User!!!"'"", user);
            response.json(user);
        })
        .catch(err => console.log(err));
};" >> server/controllers/users.controller.js


echo module.exports.createUser" = (request, response) => {
    Users.create(request.body)
        .then(user => response.json({'"message"' : '"User successfully created!!!!!"', '"newUser"' : user }))
        .catch(err => response.json({""'"message"'"" : ""'"Error user could not be created!!!!"'""}));
};" >> server/controllers/users.controller.js

echo module.exports.updateUser" = (request, response) => {
    Users.findOne({_id: request.params.id})
        .then(user => {
            request.body.firstName ? user.firstName = request.body.firstName : '""';
            request.body.lastName ? user.lastName = request.body.lastName : '""';
            user.save();
            response.json({""'"message"'"" : ""'"User successfully updated!"'"", ""'"user"'"" : user});
        });
};" >> server/controllers/users.controller.js


echo module.exports.deleteUser" = (request, response) => {
    Users.deleteOne({_id: request.params.id})
        .then(response.json({""'"message"'"" : ""'"User successfully deleted!!!"'""}))
        .catch(response.json({""'"message"'"" : ""'"Error unable to delete user!!"'""}));
};" >> server/controllers/users.controller.js

mkdir server/routes
touch server/routes/users.routes.js

# Set up Express routing 
echo "console.log('*******ROUTES*******');" >> server/routes/users.routes.js
echo "const { Router } = require('express');" >> server/routes/users.routes.js
echo "const UsersController = require('../controllers/users.controller');" >> server/routes/users.routes.js
echo "module.exports = (app) => {
    app.get('/api/users', UsersController.getAllUsers);
    app.get('/api/user/:id', UsersController.getUser, (req, res) => {res.send(req.params)});
    app.put('/api/user/:id', UsersController.updateUser, (req, res) => {res.send(req.params)});
    app.post('/api/users/create', UsersController.createUser);
    app.delete('/api/user/:id', UsersController.deleteUser, (req, res) => {res.send(req.params)});
};" >> server/routes/users.routes.js


#Set up Models
mkdir server/models
echo "console.log('*******MODELS*******');" >> server/models/users.model.js
echo "const mongoose = require('mongoose');" >> server/models/users.model.js
echo "
const UserSchema = new mongoose.Schema({
    firstName: { type: String },
    lastName: { type: String },
    email: { type: String },
    password: { type: String },
    confirm_pw: { type: String }
}, { timestamps: true });" >> server/models/users.model.js
echo "module.exports = mongoose.model('user', UserSchema);" >> server/models/users.model.js


# Setting up mongoose so you can connect node and javascript files to mongo database
read -p "Enter database name...   press enter to just use project name as database name.       " DB_NAME
n=${#DB_NAME}
if [ $n -lt 1 ]
then
    DB_NAME=$PROJECTNAME
fi
DB_PATH="mongodb://127.0.0.1:27017/${DB_NAME}"
mkdir server/config
touch server/config/mongoose.config.js

echo "
console.log('********CONFIG*******');

const mongoose = require('mongoose');

mongoose.connect('${DB_PATH}', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('Established a connection to the database!!!!!!!'))
    .catch(err => console.log('Something went wrong when connecting to the database', err));" >> server/config/mongoose.config.js



#Set up Front End
cd client
npm install axios
npm install react-router-dom

# mkdir src
mkdir src/components
mkdir src/components/UserForm
touch src/components/UserForm/index.js

# Create registration form so users can register
echo "
import React, { useState } from 'react';
import axios from 'axios';

const UserForm = (props) => {
    const [firstName, setFirstName] = useState('""');
    const [firstNameError, setFirstNameError] = useState('""');
    const [lastName, setLastName] = useState('""');
    const [lastNameError, setLastNameError] = useState('""');
    const [email, setEmail] = useState('""');
    const [emailError, setEmailError] = useState('""');
    const [password, setPassword] = useState('""');
    const [passwordError, setPasswordError] = useState('""');
    const [passwordConfirmation, setPasswordConfirmation] = useState('""');
    const [confirmationError, setConfirmationError] = useState('""');

    const {users, setUsers} = props;

    const [formError, setFormError] = useState('""');

    const handleFirstname = (e) => {
        setFirstName(e.target.value);

        if(e.target.value.length < 2) {
            setFirstNameError('First name field must be atleast 2 characters in length.');
        } else {
            setFirstNameError('""');
        }
    };

    const handleLastname = (e) => {
        setLastName(e.target.value);

        if(e.target.value.length < 2) {
            setLastNameError('Last name field must be atleast 2 characters in length.');
        } else {
            setLastNameError('""');
        }
    };

    const handleEmail = (e) => {
        setEmail(e.target.value);

        if(e.target.value.length < 5) {
            setEmailError('Email field must be atleast 5 characters in length.');
        } else {
            setEmailError('""');
        }
    };

    const handlePassword = (e) => {
        setPassword(e.target.value);

        if(e.target.value.length < 8) {
            setPasswordError('Password must be atleast 8 characters in length.');
        } else {
            setPasswordError('""');
        }
    };

    const handlePasswordConfirmation = (e) => {
        setPasswordConfirmation(e.target.value);

        console.log('*****PW', password, ' \n Confirmation', passwordConfirmation, password === passwordConfirmation );

        if(e.target.value.length < 8) {
            setConfirmationError('Input for Confirm Password must be atleast 8 characters.');
        } else {
            setConfirmationError('""');
        }
    };

    const createUser = (e) => {

        e.preventDefault();

        // const newUser = {
        //     username: username,
        //     email: email,
        //     password: password
        // };

        // or 

        if(firstName.length != 0 && lastName.length != 0 && email.length != 0 && password.length != 0 && passwordConfirmation.length != 0) {
            axios.post('http://localhost:8000/api/users/create', {
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                confirm_pw: passwordConfirmation
            })
                .then(res => {
                    console.log('Creating user!!! Sending Form!!', res);
                    console.log(res.data);
                    setUsers([...users, res.data.newUser])
                })
                .catch(err => console.log((err)));

            const newUser = { firstName, lastName, email, password, passwordConfirmation };

            console.log('Welcome', newUser);

            setFirstName('""');
            setLastName('""');
            setEmail('""');
            setPassword('""');
            setPasswordConfirmation('""');
        } else {
            setFormError('Form is invalid!');
        };

    };

    return (
        <div>
            <br/>
            <br/>
            {formError ? <p>{ formError }</p> : null }
            <br/>
            <form onSubmit={ createUser }>
                <div>
                    <label>First Name: </label>
                    <input type='text' onChange={ handleFirstname } value={ firstName } />
                </div>
                {firstNameError ? <p>{ firstNameError }</p> : null }
                <div>
                    <label>Last Name: </label>
                    <input type='text' onChange={ handleLastname } value={ lastName } />
                </div>
                {lastNameError ? <p>{ lastNameError }</p> : null }
                <div>
                    <label>Email: </label>
                    <input type='text' onChange={ handleEmail } value={ email } />
                </div>
                {emailError ? <p>{ emailError }</p> : null }
                <div>
                    <label>Password: </label>
                    <input type='text' onChange={ handlePassword } value={ password } />
                </div>
                {passwordError ? <p>{ passwordError }</p> : null }
                <div>
                    <label>Confirm Password: </label>
                    <input type='text' onChange={ handlePasswordConfirmation } value={ passwordConfirmation } />
                </div>
                {confirmationError ? <p>{ confirmationError }</p> : null }
                {passwordConfirmation != password ? <p>Passwords do not match!</p> : null }
                {
                    firstNameError ? 
                        <input type='submit' value='Submit' disabled/>
                    :
                    lastNameError ?
                        <input type='submit' value='Submit' disabled/>
                    :
                    emailError ?
                        <input type='submit' value='Submit' disabled/>
                    :
                    passwordError ? 
                        <input type='submit' value='Submit' disabled/>
                    :
                    passwordConfirmation != password ?
                        <input type='submit' value='Submit' disabled/>
                    :
                        <input type='submit' value='Submit'/>
                }
            </form>
        </div>
    );

};

export default UserForm;
" >> src/components/UserForm/index.js

# Delete react App.js boilerplate greeting
sed '7,20d' src/App.js > tmpfile.txt
mv tmpfile.txt src/App.js

# Setting up React routing and replacing html boilerplate with views
gsed -i "3i import {BrowserRouter, Routes, Route} from 'react-router-dom';" src/App.js
gsed -i "4i import Main from './views/Main';" src/App.js

gsed -i "9i <BrowserRouter>" src/App.js
gsed -i "10i <Routes>" src/App.js
gsed -i "11i <Route element={<Main/>} path='/' default />" src/App.js
gsed -i "12i </Routes>" src/App.js
gsed -i "13i </BrowserRouter>" src/App.js

gsed -i "3i import UserForm from './components/UserForm/index';" src/App.js

# Set up views
mkdir src/views
touch src/views/Main.js

echo "
import React, { useState } from 'react'
import axios from 'axios';

import UserForm from '../components/UserForm/index';
import UserList from '../components/UserList/index';

const Main = (props) => {

    const [allUsers, setAllUsers] = useState([]);

    return (
        <div>
            <UserForm users={allUsers} setUsers={setAllUsers} />
            <hr/>
            <UserList users={allUsers} setUsers={setAllUsers} />

        </div>
    )

};
export default Main;
" >> src/views/Main.js

# Display all Users on the client side front end
mkdir src/components/UserList
touch src/components/UserList/index.js

echo "

import React, {useState, useEffect} from 'react';
import axios from 'axios';

const UsersList = (props) => {
    const {users, setUsers} = props;


    useEffect(() => {
        axios.get('http://localhost:8000/api/users')
        .then((res) => {
            console.log(res.data);
            setUsers(res.data);
        })
        .catch((err) => {
            console.log(err);
        })
    }, []);

    console.log('TESTING...', users);

    return (
        <div>
            {
                users.map((user, index) => {
                    return <p key={ index } >{ user.firstName }, { user.lastName }</p>
                })
            }
        </div>
    )

}

export default UsersList;

" >> src/components/UserList/index.js

# rm -rf $PROJECTPATH

# ls $PROJECTDIR