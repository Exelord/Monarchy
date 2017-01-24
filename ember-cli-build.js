/*jshint node:true*/
/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  var config = defaults.project.config(EmberApp.env());

  var app = new EmberApp(defaults, {
    sassOptions: {
      extension: 'sass',
    },
    'ember-bootstrap': {
      'importBootstrapFont': false
    },
    favicons: {
      faviconsConfig: {
        appName: 'Monarchy',
        appDescription: 'Monarchy is a ruby gem offering a complete solution to manage an authorization access in Ruby on Rails applications. A hierarchical structure as well as built-in roles inheritance options make it the most powerful tool to control access to application data resources.',
        developerName: 'Exelord',
        developerURL: 'www.macsour.com',
        background: '#ffffff',
        path: config.rootURL,  // Path for overriding default icons path. `string`
        url: 'https://exelord.github.io/Monarchy/images/og-image.jpg',  // Absolute URL for OpenGraph image. `string`
      }
    }
  });

  // Use `app.import` to add additional libraries to the generated
  // output files.
  //
  // If you need to use different assets in different
  // environments, specify an object as the first parameter. That
  // object's keys should be the environment name and the values
  // should be the asset to use in that environment.
  //
  // If the library that you are including contains AMD or ES6
  // modules that you would like to import into your application
  // please specify an object with the list of modules as keys
  // along with the exports of each module as its value.
  app.import('bower_components/animate.css/animate.min.css');
  app.import('bower_components/wow/dist/wow.min.js');
  app.import('bower_components/bootstrap/dist/js/bootstrap.min.js');
  app.import('bower_components/isMobile/isMobile.min.js');

  return app.toTree();
};
