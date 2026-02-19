**Things done**

Made on/off UI switch for tuner and plugged it into the main UI (~20 min)  

Started creating the tuning standard UI element and debugged a bunch of random things on Phone b/c sim isn't good for this part (~1hr)  
Including:  
Correct Spacing around text elements  
Tap to make keyboard go away  
Cursor starting at the end of the text field not the beginning 

Day 2 (~1hr 30 min)  
Qualified user input for tuning standard to a given range [400, 460]  
Realized cursor fix didn't work, realized its a builtin UI element thing, moved on  


Installed homebrew, python, pip (~30 min) 

Installed tensorflow, coremltools, crepe libraries (~10 min)


Made scripts to change crepe to coreml, uninstalled tensorflow and reinstalled tensorflow-macos version 2.12 (version that works with coreml) (~4hours 15 min)


Difficulties: 
Tried using a saved model and .signatures ["serving_default"] to get at the concrete function and just save the model -- didn't work  
Tried using tf.function.get_concrete_function instead -- didn't work  
Saw that .convert can also just take the savedmodel itself instead of just the concrete function  
Plopped it in and it worked  
