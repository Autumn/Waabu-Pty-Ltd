<!DOCTYPE html><html lang="en" ng-app="myApp" class="ng-scope"><head><style type="text/css">@charset "UTF-8";[ng\:cloak],[ng-cloak],[data-ng-cloak],[x-ng-cloak],.ng-cloak,.x-ng-cloak,.ng-hide{display:none !important;}ng\:form{display:block;}</style>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Waabu Cloud Services</title>
  <meta name="fragment" content="!">
  <meta name="description" content="Cloud Hosting by Waabu - Enjoy fast, simple and easy app &amp; cloud hosting, powered by our Waabs. Our powerful virtual servers are engineered to bring you hosting power to each person or business">
  <meta name="keywords" content="cloud server, cloud hosting, vps, vps server, vps server hosting, vps hosting, virtual server, virtual private server, ubuntu server, centos server, debian server, linux server, fedora server, linux mint server, web hosting, waabu, waabs, waabu cloud">

<link href="//fonts.googleapis.com/css?family=Lato:400,900italic,700italic,400italic,300,700,900,300italic,100italic,100" rel="stylesheet" type="text/css">

  <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css">
  <link rel="stylesheet" href="css/app.css">

  <link rel="stylesheet" href="css/tiles.css">
  <link rel="stylesheet" href="corewaab/css/style.css">
  <link rel="stylesheet" href="webwaab/css/style.css">
  <link rel="stylesheet" href="corewaab/config/css/style.css">

<link rel="icon" href="favicon.ico" type="image/x-icon">




</head>

<body>
   <div id="waabu-wrap">
      <div id="waabu-header">
         <waabu-menu><div ng-controller="MenuCtrl" class="ng-scope">
  <div class="navbar navbar-default navbar-fixed-top" role="navigvation" style="">
    <div class="container">
      <div class="navbar-header">
        <button class="navbar-toggle" data-target=".navbar-collapse" data-toggle="collapse" type="button">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a href="#/" class="brand">
          <div>
            <img src="img/logo-large.png" height="60px" width="60px">
            <span class="title">Waabu</span>
          </div>
        </a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="dropdown">
              <a href="" class="dropdown-toggle" data-toggle="dropdown" data-hover="dropdown" data-delay="500">Cloud Services</a>
              <ul class="dropdown-menu" style="box-shadow: none; ">
            	<li><a href="#/waabCloudHosting">Waabs</a></li>
              </ul>
            </li>
            <li><a href="#/features">Features</a></li>
          </ul>
	  <ul class="nav navbar-nav navbar-right">

            <li class="dropdown">
              <a href="" class="dropdown-toggle" data-toggle="dropdown" data-hover="dropdown" data-delay="500">
            Checkout <span class="glyphicon glyphicon-shopping-cart"></span>(<span ng-bind="cartService.cartSize()" class="ng-binding">0</span>)</a>

              <ul class="dropdown-menu" style="box-shadow: none;">
            	<!-- ngRepeat: item in cartService.cart track by $index -->
                <li ng-show="cartService.cartSize() == 0" class="">No items.</li>
                <li ng-show="cartService.cartSize() &gt; 0" style="border-top: 1px solid whitesmoke;" class="ng-hide"><a href="" ng-click="sendToCheckout()">Checkout</a></li>
              </ul>
            </li>

            <li><a href="https://dashboard.waabu.com">Log in</a></li>
            <li><a href="#/register">Sign up</a></li>
          </ul>
        </div><!--/.nav-header -->
      </div>
    </div>
    
  </div>

</waabu-menu>
      </div>
      <div id="waabu-main" style="height:100%;">
         <!-- ngView:  --><div ng-view="" autoscroll="false" class="reveal-animation ng-scope" style=""><div id="waabu-content" class="ng-scope"> 
  <div class="landing-header">

  <div class="container">
    <div class="row text-center heading-space">
      <span class="heading">Cloud hosting that's easy to use.</span>
    </div>

    <div class="row heading-space text-center">
       <span class="subheading">Connect to a SSD Cloud Server in less than a minute.</span>
    </div>

      <div class="text-center col-md-6 col-md-offset-3 signup-form heading-space">	
          <landing-reg><div ng-controller="RegisterCtrl" class="ng-scope">
  <div class="row">
    <span class="form-padding">
      <input ng-model="email" type="email" class="input form-control ng-pristine ng-valid ng-valid-email" placeholder="Email">
    </span>

    <span class="form-padding">
      <input ng-model="password" type="password" class="input form-control ng-pristine ng-valid" placeholder="Password">
    </span>
  </div>
  <div class="row text-center">
    <span class="form-padding">
      <a class="form-button" href="" ng-click="register()">Create Account</a>
    </span>
  </div>

  <div class="form-alerts">
    <div class="row">
      <div class="col-md-12">
    <div ng-show="nullemailerror" class="alert alert-danger tile-error ng-hide">Please enter a valid email address.</div>
    <div ng-show="nullpassworderror" class="alert alert-danger tile-error ng-hide">Please enter a password.</div>
    <div ng-show="passwordtooshorterror" class="alert alert-danger tile-error ng-hide">Password must be longer than 8 characters.</div>
    <div ng-show="passwordtoolongerror" class="alert alert-danger tile-error ng-hide">Password must be shorter than 72 characters.</div>
    <div ng-show="success" class="alert alert-success tile-success ng-hide">Registered successfully. You'll receive an email with details shortly.</div>
    <div ng-show="failure" class="alert alert-danger tile-error ng-hide">Registration failed. Please check your details.</div>
      </div>
    </div>
  </div>
</div>
</landing-reg>
      </div>

    </div> 
  </div>
  <div class="container ng-scope" ng-controller="WaabSelectCtrl">
    <div class="marketing-block light-blue-block">
      <div class="marketing-heading text-center">
          Get started online in only three steps.
      </div>
      <div class="row landing-tiles" style="padding: 45px;">
        <div class="col-md-3 col-md-offset-3 tile-space" style="padding:30px">
          <waabu-service-box content="serviceOne" class="ng-isolate-scope"><div class="landing-tile purple">
  <div class="purple-header">
    <div class="row">
      <div class="col-xs-12 col-md-12 heading ng-binding">
	BaseWaab
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-xs-6 col-md-6 value ng-binding">
	0.5GB
    </div>
    <div class="col-xs-6 col-md-6 key">
	RAM 
    </div>
  </div>
  <div class="row">
    <div class="col-xs-6 col-md-6 value ng-binding">
      2
    </div>
    <div class="col-xs-6 col-md-6 key">
	CPU 
    </div>
  </div>
  <div class="row">
    <div class="col-xs-6 col-md-6 value ng-binding">
	10GB
    </div>
    <div class="col-xs-6 col-md-6 key">
	SSD
    </div>
  </div>

  <div class="row">
    <div class="col-xs-12 col-md-12 pricing">
      <span class="monthly-price ng-binding">$9<span class="price-subscript">/mo</span></span>
    </div>
  </div>
  <div class="row">
    <div class="col-md-12 buttons">
      <a class="button purple-button" href="" ng-click="selectService()">Buy</a>
    </div>
  </div>
</div> 
</waabu-service-box>
        </div>
        <div class="col-md-3 tile-space" style="padding:30px">
          <waabu-service-box content="serviceTwo" class="ng-isolate-scope"><div class="landing-tile cyan">
  <div class="cyan-header">
    <div class="row">
      <div class="col-xs-12 col-md-12 heading ng-binding">
	CoreWaab
      </div>
    </div>
  </div>
  <div class="row">
    <div class="col-xs-6 col-md-6 value ng-binding">
	1GB
    </div>
    <div class="col-xs-6 col-md-6 key">
	RAM 
    </div>
  </div>
  <div class="row">
    <div class="col-xs-6 col-md-6 value ng-binding">
      2
    </div>
    <div class="col-xs-6 col-md-6 key">
	CPU 
    </div>
  </div>
  <div class="row">
    <div class="col-xs-6 col-md-6 value ng-binding">
	20GB
    </div>
    <div class="col-xs-6 col-md-6 key">
	SSD
    </div>
  </div>

  <div class="row">
    <div class="col-xs-12 col-md-12 pricing">
      <span class="monthly-price ng-binding">$18<span class="price-subscript">/mo</span></span>
    </div>
  </div>
  <div class="row">
    <div class="col-md-12 buttons">
      <a class="button cyan-button" href="" ng-click="selectService()">Buy</a>
    </div>
  </div>
</div> 
</waabu-service-box>
        </div>
      </div>
    </div>
    <div>
      <div class="row">
        <div class="waablink light-blue-block" style="padding-bottom: 90px;">
          <div class="container">
            <div class="row">
              <div class="col-md-12 text-center" style="margin: auto;">
		<a class="light-blue-button button" href="#/waabCloudHosting">Or browse our full range of offerings.</a>
	      </div>
	    </div>
	  </div>
	</div>
      </div>
    </div>
  </div>

  <div class="marketing">
    <div class="container">
      <div class="row text-center">
        <span style="padding:30px; font-style: italic; font-size: 64px;" class="heading">Waabu who?</span>
        <span style="padding:30px; font-weight: 300; color: #e8f2f7;" class="copy">Waabu is a cloud company, and our mission is simple: We take care of the technical side so you can spend your time creating and developing.</span>
      </div>
    </div>
  </div>

  <div class="marketing">
    <div class="container">
      <div class="row text-center">
        <span class="heading">The Waabu Cloud works for you.</span>
        <span class="copy">From our hardware to our hard working team, the Waabu Cloud is dedicated to bringing the best possible cloud experience to you.</span>
      </div>
      <div class="row">
        <span class="text-center heading">Get online quickly.</span>
        <span class="copy text-center">We're dedicated to bringing you the easiest, most intuitive computing experiences. Set up a server with all the software you'll ever need, with just a few clicks.</span>
      </div>
      <div class="row">
        <span class="text-center heading">Forget about hardware.</span>
        <span class="copy text-center">We deal only with the highest quality components for our platform. Worry no longer about the performance of your local machine, just think Waabu.</span>
      </div>

    </div>
  </div>

  <div class="marketing">
    <div class="container">
      <div class="row text-center">
	<span class="heading">
	  Interested?
	</span>
      </div>
      <div class="row">
	<div class="waablink" style="padding-bottom: 90px; border-radius:0px;">
	  <div class="container">
	    <div class="row">
	      <div class="col-md-12 text-center" style="margin: auto;">
		<a class="light-blue-button button" href="#/coreWaab" style="line-height:inherit;">Browse our full range of offerings.</a>
	      </div>
	    </div>
	  </div>
	</div>
      </div>
    </div> 
  </div>

  <div id="waabu-footer">
    <waabu-footer><!-- div style="background-color: #808080;" -->
<div class="footer">

  <div class="container">


    <div class="row">

      <div class="col-md-3">
        <ul>
        <li><span class="heading">Overview</span></li>
	<li><a href="#/coreWaab">Plans &amp; Pricing</a></li>
	<li><a href="#/features">Features</a></li>
	<li><a href="#/comingsoon">Dashboard</a></li>
        </ul>
      </div>
      <div class="col-md-3">
	<ul>
        <li><span class="heading">Community</span></li>
	<li><a href="#/comingsoon">Tutorials</a></li>
	</ul>
      </div>

      <div class="col-md-3">

	<ul>
        <li><span class="heading">Company</span></li>
	<li><a href="#/company">About Us</a></li>
	<li><a href="#/comingsoon">Blog</a></li>
	<!--li><a href="#/contact">Contact</a></li-->
	</ul>

      </div>


      <div class="col-md-3">
	<ul>
        <li><span class="heading">Connect</span></li>
	<li><a href="#/comingsoon">Google+</a></li>
	<li><a href="https://www.facebook.com/WaabuCloud">Facebook</a></li>
	<li><a href="https://twitter.com/WaabuCloud">Twitter</a></li>
	<li><a href="//linkedin.com/company/waabu">LinkedIn</a></li>
	</ul>
      </div>


    </div>
  </div>
<div class="container">
	<!--div id="footer-copyright" class="row"-->
        <div class="row" style="padding:30px;">
		
	<div class="col-sm-2 col-sm-offset-3">
	© 2014  Waabu Pty Ltd 
	</div>

	<div class="col-sm-2">
	<a href="#/termsOfService">Terms of Service</a>
	</div>

	<div class="col-sm-2">
	<a href="#/privacyPolicy">Privacy Policy</a>
	</div>

	</div>
</div>

</div>
</waabu-footer>
  </div>
</div>
</div>
      </div>
   </div>



  
  
  
  
  
  
  
  
  
  
  


</body></html>