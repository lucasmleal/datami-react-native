   const path = require('path');
   const fs = require('fs');
   const glob = require('glob');
   const xml = require('xmldoc');
   const DOMParser = require('xmldom').DOMParser;
   const XMLSerializer = require('xmldom').XMLSerializer;

   function findAndroidAppFolder(folder) {
      const flat = 'android';
      const nested = path.join('android', 'app');
      console.log(nested);
      if (fs.existsSync(path.join(folder, nested))) {
         return nested;
     }
     if (fs.existsSync(path.join(folder, flat))) {
         return flat;
     }
     return null;
   };

   function findManifest(folder) {
      const manifestPath = glob.sync(path.join('**', 'AndroidManifest.xml'), {
       cwd: folder,
       ignore: ['node_modules/**', '**/build/**', 'Examples/**', 'examples/**','**/debug/**'],
      })[0];

      return manifestPath ? path.join(folder, manifestPath) : null;
   };

   function readManifest(manifestPath) {
      return new xml.XmlDocument(fs.readFileSync(manifestPath, 'utf8'));
   };

   const getPackageName = (manifest) => manifest.attr.package; 

   function getApplicationClassName(folder) {
      const files = glob.sync('**/*.java', { cwd: folder });

      const packages = files
       .map(filePath => fs.readFileSync(path.join(folder, filePath), 'utf8'))
       .map(file => file.match(/class (.*) implements ReactApplication/))
       .filter(match => match);

      return packages.length ? packages[0][1] : null;
   };

   // String append
   function insert(str, index, value) {
      return str.substr(0, index) + value + str.substr(index);
   }

   function findStringsXml(folder) {
      console.log('findStringsXml()');
      const stringsXmlPath = glob.sync(path.join('**', 'strings.xml'), {
       cwd: folder,
       ignore: ['node_modules/**', '**/build/**', 'Examples/**', 'examples/**'],
      })[0];

      return stringsXmlPath ? path.join(folder, stringsXmlPath) : null;
   };


   // update string.xml file
   function updateConfigurationFile(confFilePath){
      console.log('updateConfigurationFile()');
      const smisdkApikey = '\n<string name="smisdk_apikey"></string>';
      const smisdkShowMessaging = '\n<bool name="smisdk_show_messaging">true</bool>';
      const smisdkExclusionDomin = '\n<array name="smisdk_exclusion_domin"></array>';
     
      var stringsXmlDoc= fs.readFileSync(confFilePath, 'utf8');
      var resourcesEndIndex = stringsXmlDoc.search("</resources>")
      if(stringsXmlDoc.search('smisdk_apikey')<0){
         stringsXmlDoc = insert(stringsXmlDoc, resourcesEndIndex-1, smisdkApikey);
      }
      if(stringsXmlDoc.search('smisdk_show_messaging')<0){
         stringsXmlDoc = insert(stringsXmlDoc, resourcesEndIndex-1, smisdkShowMessaging);
      }
         if(stringsXmlDoc.search('smisdk_exclusion_domin')<0){
         stringsXmlDoc = insert(stringsXmlDoc, resourcesEndIndex-1, smisdkExclusionDomin);
      }
      fs.writeFileSync(confFilePath, stringsXmlDoc, 'utf8');
   }

   // update manifest file with app name
   function updateManifestFile(manifestPath, applicationClassName) {
      console.log('updateManifestFile()');
      var manifestXmlDoc= new DOMParser().parseFromString(fs.readFileSync(manifestPath, 'utf8'));
      var attrApplication = manifestXmlDoc.getElementsByTagName("application");
      // console.log('attrApplication:' + attrApplication[0]);
      const attrApplicationLength = attrApplication[0].attributes.length;
      console.log('attrApplicationLength:' + attrApplicationLength);
      // insert/update android:name attribute to manifest

      var i;
   	for (i = 0; i < attrApplicationLength; i++) {
       	var attrNodeName = attrApplication[0].attributes[i].nodeName;
       	console.log('attrNodeName:' + attrNodeName);
       	if(attrNodeName.search('android:name')>=0){
       		var attrNodeValue = attrApplication[0].attributes[i].nodeValue;
       		console.log('attrNodeValue:' + attrNodeValue);
       		if(attrNodeValue === ('.'+applicationClassName)){
       		   console.log('app class name matched');
       		}else{
       			console.log('app class name not matched:' + applicationClassName);
       			attrApplication[0].removeAttribute(attrApplication[0].attributes[i].nodeName);
   				attrApplication[0].setAttribute('android:name ', '.' +applicationClassName);
       			fs.writeFileSync(manifestPath, manifestXmlDoc, 'utf8');
       		}
       		break;
       	}
       	else if (i == attrApplicationLength-1){
       		// android:name does not exist
       		console.log('android:name does not exist in manifest file');
       		attrApplication[0].setAttribute('android:name ', '.' +applicationClassName);
       		fs.writeFileSync(manifestPath, manifestXmlDoc, 'utf8');
       	}
   	}
   }


   //// Main function to perform integration
   function projectConfigAndroid(folder) {
      const androidAppFolder = findAndroidAppFolder(folder);
      console.log('Folder : '+folder+" app folder : "+androidAppFolder);

      if (!androidAppFolder) {
     	   console.log('App folder not available.');
         return null;
      }

      const sourceDir = path.join(folder, androidAppFolder);
      console.log('sourceDir: ' + sourceDir);

      const manifestPath = findManifest(sourceDir);
      console.log('manifestPath: ' + manifestPath);

      if (!manifestPath) {
          return null;
      }

   // check app class Availability

      var applicationClassName = getApplicationClassName(sourceDir+'/src/main')
      console.log('applicationClassName before:' + applicationClassName); 
      if(applicationClassName == null){
      	// Application class not available. 
     	   //Copy application class and update manifest with application name

      	const manifest = readManifest(manifestPath);
      	const packageName = getPackageName(manifest);
        console.log("Package Name ===> ",packageName);
      	const packageNameStr = "package " + packageName + ';\n';
      	const packageFolder = packageName.replace(/\./g, path.sep);
      	const appPackagePath = path.join(sourceDir,`src/main/java/${packageFolder}`);

      	var datamiAppFile = fs.readFileSync('ApplicationClass.txt', 'utf8')
      	if(datamiAppFile.search(packageNameStr)<0){
      		var datamiAppFile = insert(datamiAppFile, 0, packageNameStr);
      	}
      	var datamiApplicationClassName = 'MainApplication';
      	fs.writeFileSync(appPackagePath+'/' + datamiApplicationClassName + '.java', datamiAppFile, 'utf8');

      	// update manifest with app name
      	updateManifestFile(manifestPath, datamiApplicationClassName);
        
         // update configuration file
         const stringsXmlPath = findStringsXml(sourceDir);
         console.log('stringsXmlPath: ' + stringsXmlPath);
         if(stringsXmlPath!=null){
            updateConfigurationFile(stringsXmlPath);
         }
      }
     else{
     	   // Application class available
     	   var applicationClassNameSplit = applicationClassName.split(' ');
     	   if(applicationClassNameSplit.length > 0){
     	      applicationClassName = applicationClassNameSplit[0];
     		   console.log('applicationClassName after:' + applicationClassName);

     		   const manifest = readManifest(manifestPath);
           console.log("manifest ===> ",manifest);
   		   const packageName = getPackageName(manifest);
   		    console.log('packageName: ' + packageName);
   		   const packageFolder = packageName.replace(/\./g, path.sep);
   		     console.log('packageFolder: ' + packageFolder);
     		   const mainApplicationPath = path.join(sourceDir, 
     			`src/main/java/${packageFolder}/${applicationClassName}.java`);
     	      console.log('mainApplicationPath: ' + mainApplicationPath);

   		   //Read application class
   	      const appFile = fs.readFileSync(mainApplicationPath, 'utf8');
   	      var isPackageExist = appFile.search('SmiSdkReactPackage');
   	      console.log('isPackageExist: ' + isPackageExist);
   	      if(isPackageExist<0){
   		 	  const smiPackageName = ', new SmiSdkReactPackage()';
   		 	
   		     const packageImport = 'import com.datami.smi.SdStateChangeListener; \nimport com.datami.smi.SmiResult; \nimport com.datami.smi.SmiSdk; \nimport com.datami.smisdk_plugin.SmiSdkReactModule; \nimport com.datami.smisdk_plugin.SmiSdkReactPackage; \n';
   		 	
   		 	  const initSponsoredDataAPI = '\nSmiSdk.initSponsoredData(getResources().getString(R.string.smisdk_apikey), \nthis, null, R.mipmap.ic_launcher,\ngetResources().getBoolean(R.bool.smisdk_show_messaging),\nArrays.asList(getResources().getStringArray(R.array.smisdk_exclusion_domin)));';
   		 	
   		 	  const onCreateMethod = '\n @Override \n public void onCreate() { \n  super.onCreate();'+ initSponsoredDataAPI + ' \n}'; 	
   		 	
   		 	  const stateChangeListnerStr = ' SdStateChangeListener, ';

   			  const onChangeMethod = '\n@Override \n public void onChange(SmiResult smiResult) {\n SmiSdkReactModule.setSmiResultToModule(smiResult);\n}';

   		 	  var intMainPackageIndex = appFile.search("new MainReactPackage()")
   		 	  console.log('intMainPackageIndex: ' + intMainPackageIndex);
   		 	  if(intMainPackageIndex>0){
   		 			// add package name
   		 			var appfileNew = insert(appFile, intMainPackageIndex+22, smiPackageName);
   		 			// add import
   		 			var intImportIndex = appFile.search("import")
   		 			appfileNew = insert(appfileNew, intImportIndex, packageImport);

   		 			//add sdStateChangeListner
   		 			var implementsIndex = appfileNew.search("implements");
   		 			if(implementsIndex>0){
   		 				appfileNew = insert(appfileNew, implementsIndex+10, stateChangeListnerStr);
   		 			}
   		 			// add initSponsoredData Api
   		 			var intSuperIndex = appfileNew.search("super.onCreate()");
   		 			console.log('intSuperIndex: ' + intSuperIndex);
   		 			if(intSuperIndex>0){
   		 				appfileNew = insert(appfileNew, intSuperIndex+17, initSponsoredDataAPI);
   		 			}else{
   					    // add onCreate method with initSponsoredData API
   						var n = appfileNew.lastIndexOf("}");
   						console.log('lastIndexOf }: ' + n);
   						appfileNew = insert(appfileNew, n-1, onCreateMethod);
   		 			}

   		 			// add onChange method
   						var lastchar = appfileNew.lastIndexOf("}");
   						appfileNew = insert(appfileNew, lastchar-1, onChangeMethod);

   		 			fs.writeFileSync(mainApplicationPath, appfileNew, 'utf8');
   		 			// const appFileNew2 = fs.readFileSync(mainApplicationPath, 'utf8')
   		 			updateManifestFile(manifestPath, applicationClassName);
                  // update configuration file
                  const stringsXmlPath = findStringsXml(sourceDir);
                  console.log('stringsXmlPath: ' + stringsXmlPath);
                  if(stringsXmlPath!=null){
                     updateConfigurationFile(stringsXmlPath);
                  }
             
   	 		   }
   	 		else{
   	 			console.log('Error MainReactPackage does not exist.');
   	 		}
    		}
    		else{
    			console.log('SmiSdkReactPackage already exist.');
    		}
     	}
     	else{
     		console.log('Error in getting applicationClassName.');
     	}
   }
   /////////////////////////////////////////////////////////////////////////////////////////////////////
};

projectConfigAndroid('../..')



