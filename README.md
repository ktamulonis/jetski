# 🌊 Jetski MVC framework for Ruby. 

### Installation guide

`gem install jetski`

### Creating an app

After installing the jetski gem you can use the jetski command in your terminal to generate new apps

`jetski new my-app`


### Hosting Assets

To include external asset files such as CSS stylesheets and images you can put them in the assets folder under the corresponding file type

### CSS 

for css files put them in the `/app/assets/stylesheets` folder. Jetski will automatically search for a matching css file that matches your controller name.

For example if you have a pages_controller it will look for a matching pages.css file located at `/app/assets/stylesheets/pages.css`

To access the files just go to the name of the file in the browser `localhost:8000/pages.css`

You can use this to include the CSS file manually as well

Add this to head section in html 

```html
<link rel="stylesheet" type="text/css" href="/pages.css">
```

### Images

for image files you can put them in `app/assets/images` Jetski will find these matching image files and host them with them being available through the url.

For example adding a file `test-image.jpg` to the `app/assets/images` folder with a final path of `app/assets/images/test-image.jpg` will now be automatically available through the url `localhost:8000/test-image.jpg`

You can use this to for image sources on the page like so

```html
<img src="/test-image.jpg" width="300px" height="400px"/>
```

or use the ruby helper method

```
<%= image_tag "test-image.jpg", width: "300px", height: "400px" %>
```


### Javascript

To use custom Javascript files you can stick them in the `app/assets/javascript` folder
they will be automatically included if the name of the file matches the controller name.

for examples for a pages controller and home action it would automatically include the following JS file if it exists `app/assets/javascript/pages.js`

The `application.js` file is automatically included on all pages

### Routing

I initially had used a routes file where you could define your routes manually similar to Rails but than I thought that maybe it would be cool if we could have our routes be defined easier and automatically from the controller we are using. This will reduce the amount of files needed to change when building a new feature which does save time.

In my solution the routes are automatically created by the controller name and the action name it supports the default CRUD methods similar to rails and will set the HTTP method used automatically.

```ruby
class PostsController < Jetski::BaseController
  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
```
Creates these route

```routes
  GET /posts/new
  POST /posts
  GET /posts/:id
  GET /posts/:id/edit
  PUT /posts/:id
  DELETE /posts/:id
```

For any other method name it will use a GET http method by default but to override this and use a custom HTTP method you can use the route method `route :index, root: true` line in the action to change the request method it looks for.

```ruby
class PostsController < Jetski::BaseController
  route :save, root: true
  def save
    # do the saving logic
  end
end
```

Creates this route: "POST /posts/save"

To set the root of the app use the route method and simply set the root keyword to true

```ruby
class PagesController < Jetski::BaseController
  route :home, root: true
  def home
  end
end
```

Set a custom url path by setting the path variable in your action
currently setting the path and request_method only work for non CRUD named actions because those urls and methods are automatically created for now.

```ruby
class ProjectsController < Jetski::BaseController
  route :save, path: "my-custom-path"
  def save
  end
end
```

### Generators

Similar to rails we have generator commands you can use to create new resources.

#### Controllers

Generate a new controller with a name and any actions that you want to generate as well.

`jetski generate controller pages home about contact`

This will create a pages controller with 3 actions home, about, and contact.

To destroy a controller you can run the corresponding destroy command like so
passing in the action names is not required but also won't break the command.

`jetski destroy controller pages`

#### Models

Generate a new model with a name and the fields you want on the model.

`jetski generate model post title body:text`

You can specify the data type as any valid data type supported by Sqlite3. using a colon similar to how rails does it.

this generates the following model file: `models/post.rb`

```ruby
class Post < Jetski::Model
  attributes :title, body: :text
end
```

rather than how rails uses a db/migrate folder and a dsl for managing attributes jetski allows you to define your attributes inline on your model.

now run `rails db migrate` which will automatically create your table and add your fields. Whenever you want to add a new field just add it to attributes and rerun the db migrate command which will add it to the table.

to remove the model you can run the corresponding destroy command

`jetski destroy model post`

### Console

Similar to rails jetski has a console you can open which is simply a pry shell but with all of your objects from your app loaded for you to access meaning you can access your models and interact with them to debug or explore your codebase.

`jetski console`

inside of the console you can interact with the models similar to rails by using the methods available.

```ruby
  Post.create(title: "New post", body: "This is an example post")
  Post.count # 1
  Post.last  # returns the last post

  Post.all # returns an array of all objects
```

### Seed database

You can optionally create a seed.rb file in your app where you can write code to create sample records in your app. All of youre models will be available in this file similar to rails seeds file.

create a `./seed.rb` file

```ruby
10.times do
  Post.create(title: "New post", body: "example post body")
end
```

then run the command in terminal

`jetski db seed`

### Configure database library

currently the jetski framework only supports sqlite3 as the database library

in the future you would be able to create a `config.rb` file and set custom config options for jetski like changing the database library

```ruby
Jetski.config do |config|
  config.database_library = "postgresql"
end
```

### Framework description

now u can build websites even faster!

Whats faster a train or a jetski? Would you rather ride on a train or a jetski? 

This all depends on your preference but this is why I create the Jetski library for Ruby.

I wanted to see if I could create an alternative with a simpler and possibly faster approach and I realized I could do just that!


### Which would you rather ride?

![rails-jetski](https://github.com/user-attachments/assets/c72eba3d-a954-465a-be39-c1a636194c0d)

### Development mode

Testing CLI command. To test CLI command in development environment to avoid having to rebuild the command each time you can run `ruby -I lib ./bin/jetski`

To pass in a folder dir to use as the jetski route you can find the working directory of a jetski app by using `pwd` and then take that and set it as an environment variable

for example

```sh
cd jetski-app
pwd # /Users/username/apps/your-jetski-app

cd ~/jetski
ruby -I lib ./bin/jetski routes
```

This will print out the routes generated in that app.

##### bundle exec 

for testing jetski apps locally when starting the server you must use bundle exec to use the locally installed gem version instead of the globally built version which is not updated from recent code changes. 

`bundle exec jetski server`
