# BYGONE: A Soldier's tale.
Major Project for Design Computing Studio I 2017

Install dependencies with npm and bower (although bower_components is already tracked):
``` 
npm install
bower install
```

For file compilation use:
```
coffee -w -c .
node-sass -w public/stylesheets/main_style.scss main_style.css
```

For compiling typescript consider:
```
npm install -g typescript
tsc file.ts
```

Unit testing and deployment is disabled. Server requires remote VPN. Update remote files when possible with:
```
git pull --all
```
