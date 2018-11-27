Need to run this when model changes and copy output database to Diabetes project.  bundle is displayed in output and database is there upon completion.

model and managed object subclasses are from Diabetes project so no need to copy them.  Modify model and generate subclasses in Diabetes project.

Add Copy Files build rule to project so any resources get copied to bundle when project is built.  this is unique to a command line utility.  iOS projects do it for you.


