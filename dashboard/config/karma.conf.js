module.exports = function(config){
    config.set({
    basePath : '../',

    files : [
      'static/lib/angular/angular.js',
      'static/lib/angular/angular-*.js',
      'test/lib/angular/angular-mocks.js',
      'static/js/**/*.js',
      'test/unit/**/*.js'
    ],

    exclude : [
      'static/lib/angular/angular-loader.js',
      'static/lib/angular/*.min.js',
      'static/lib/angular/angular-scenario.js'
    ],

    autoWatch : true,

    frameworks: ['jasmine'],

    browsers : ['Chrome'],

    plugins : [
            'karma-junit-reporter',
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-jasmine'
            ],

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }

})}
