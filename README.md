# Plano

>  A  issues track system  base on Redmine.

## Development

after clone to local, create the config/database.yml

```
bundle install
rake db:create
rake db:migrate
rake redmine:load_default_data 
```

