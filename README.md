# Nitrogen plugin to allow you to visually view visitors & browsers used for a [Nitrogen Web Framework Project](http://nitrogenproject.com).

A means by which to either show a map based on IP lookups where the visitors for a site are via `#element_map{}`. Or a means by which to see which browser family is most commonly used on your pages using `#elemenent_ua{}`.

![Screenshot]
(https://github.com/stuart-thackray/nitrogen_user_map/blob/master/doc/screenshot.jpg)
 
## Installing into a Nitrogen Application 

You install it as a rebar dependency by adding the following in the deps section of rebar.config

```erlang
{nitrogen_user_map, "", {git, "git://github.com/stuart-thackray/nitrogen_user_map.git", {branch, master}}
```

You need to start the application in etc/vm.args in order for the information to be stored. It is stored in memory via dictionary and state information (non-persistant). 

```erlang
-eval "application:start(nitrogen_user_map)"
```


### Using Nitrogen's built-in plugin installer (Requires Nitrogen 2.2.0)

Run `make` in your Application. 

**It doesn't currently work nicely with inets and maybe other webservers** Using YAWS is safe. ( I beleive due to the CSS/JS/others files not being returned with markup information.

## Usage

You use it by calling the following in any page that you wish to record.
```erlang
num_api:call().
```

You can then use open your browser to the address of your webserver
```html
http://127.0.0.1:8000/user_map_demo
http://<IPPORT>/user_map_demo
```

Used libraries
==============

Check their libraries and deps for license(s).

Listed in no specific order

| Package | Description | 
| --- | --- |
| [Bootstrap](http://getbootstrap.com/) | Base CSS JS |
| [Nitrogen Web Framework](https://github.com/nitrogen/nitrogen) | Webserver/Web Framework |
| [Font Awesome Plugin](https://github.com/stuart-thackray/nitrogen_fa) | plugin for [Font Awesome](http://fontawesome.io/) |
| [AdminLTE](https://almsaeedstudio.com/) | The styling and idea for the plugin |
| [Erlang GEO IP](https://github.com/mochi/egeoip.git)|Library for getting the geographic information for an IP |
| [Erlang User Agent](https://github.com/ferd/useragent.git) | User-Agent lookup funcationality | 


## TODO
- [x] Get to work
- [ ] Improve coding and add additional functionality.

