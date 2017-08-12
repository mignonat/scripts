#!/usr/bin/env python
import sys
import os
import subprocess
import shutil

isPosix = not sys.platform.startswith('win')
sep = os.path.sep

plugin_customers_path = "/usr/local/nqi/dev/customers"
plugin_solutions_path = "/usr/local/nqi/dev/solutions"

#to do : get dynamically plugin customers and solutions

applications = [
	{"id": "1", "name": "HEAD", "version": "4-3", "nqi_dir": "/usr/local/nqi/dev/head/nqi"},
  	{"id": "2", "name": "4-2", "version": "4-2", "nqi_dir": "/usr/local/nqi/dev/4-2/nqi"}
]

databases = [
	{"id": "1", "name": "LOCALHOST", "version": "4-2", "file": "localhost-4-2"},
	{"id": "2", "name": "LOCALHOST", "version": "4-3", "file": "localhost-4-3"},
  	{"id": "3", "name": "ARCELOR", "version": "4-3", "file": "arcelor-4-2"}
]

plugins = []

actions = [
	{"id": "1", "type": "compilation", "name": "BIG COMPILATION", "command": "mvn clean install" },
	{"id": "2", "type": "compilation", "name": "FAST COMPILATION", "command": "mvn -FastPom" },
	{"id": "3", "type": "build", "name": "ANT", "command": "ant" },
	{"id": "4", "type": "copy", "name": "CHANGE DATABASE", "command": "cp -f"},
	{"id": "4", "type": "copy", "name": "RELOAD PLUGINS", "command": ""}
]

nqi_db_rep = "/usr/local/nqi/dev/nqidb"
nqi_db_file_end = "-nqidb-ds.xml"

db_file_name_dest = "nqidb-ds.xml"

path_jboss = "orchestra" +sep+ "jboss"
path_db_dest_rep = path_jboss +sep+ "orchestra" +sep+ "deploy"
path_platform = "platform"
path_platform_start = path_platform +sep+ "platform-start"

application = applications[0]
database = databases[0]
plugin = {}

command_separator = ";" if isPosix else "&"

def printMenuStrip():
	print '-----------------'

def printResponseStrip():
	print '#######################################################'

def cmd_str_sep():
	return ";" if isPosix else "&"

def cmd_str_cd(path):
	return "cd " + path

def cmd_ls(path):
	status = subprocess.call(("ls -ali " if isPosix else "dir ") + path, shell=True)
	if status == 0:
		return True
	else:
		return False

def cmd_mvn_cln_inst(path):
	status = subprocess.call(cmd_str_cd(path) + cmd_str_sep() + "mvn clean install", shell=True)
	if status == 0:
		print "Success for cmd 'mvn clean install' for the path : '" + path + "'"
		return True
	else:
		print "Failure for cmd 'mvn clean install' for the path : '" + path + "'"
		return False

def cmd_cp(srcRep, srcFile, destRep, destFile):
	try:
		shutil.copy(srcRep +sep+ srcFile, destRep +sep+ destFile)
		print "Successful copy of " + srcRep +sep+ srcFile + " to " + destRep +sep+ destFile
		return True
	except Exception: 
		print "Error during copy of " + srcRep +sep+ srcFile + " to " + destRep +sep+ destFile		
		return False

def cmd_cp_database_file(application_rep, fileName):
	return cmd_cp(nqi_db_rep, fileName+nqi_db_file_end, application_rep+sep+path_db_dest_rep, db_file_name_dest)

def clear_screen():
	subprocess.call(["clear" if isPosix else "cls"])

def load_plugins():
	i = 1
	for dir in os.listdir(plugin_customers_path):
		plugins.append({"id": str(i), "name": dir, "root_dir": plugin_customers_path+sep+dir, "type": "customer"})
		i += 1
	for dir in os.listdir(plugin_solutions_path):
		plugins.append({"id": str(i), "name": dir, "root_dir": plugin_customers_path+sep+dir, "type": "solution"})
		i += 1
	plugin = plugins[0]

def chooseApplication():
	applicationSelected = False
	while not applicationSelected:
		try:
			clear_screen()
			found = False
			printMenuStrip()
			print "Available applications :"
			printMenuStrip()
			for app in applications:
				print app["id"] + " : " + app["name"]
				found = True
			if not found:
				print "No application found check the config !"
			printMenuStrip()
			print "0 : QUIT APP"
			printMenuStrip()
			choice = raw_input("Select an application -> #")
			if choice == "0":
				headerMessage("Bye, see you next time !")
				sys.exit(0)
			else:
				choice = int(choice)
				application = applications[choice-1]
				applicationSelected = True
		except ValueError:
			headerMessage("Error : " + choice + " not a valid input !")

def chooseDatabase():
	databaseSelected = False
	while not databaseSelected:	
		try:				
			clear_screen()
			found = False
			printMenuStrip()
			print "Available databases for version : " + application["version"]
			printMenuStrip()
			for db in databases:
				if application["version"] == db["version"]:
					print db["id"] + " : " + db["name"]
					found = True
			if not found:
				print "No database found for this version !"
			printMenuStrip()
			print "0 : QUIT APP"
			printMenuStrip()
			choice = raw_input("Now select a database -> #")
			if choice == "0":
				headerMessage("Bye, see you next time !")
				sys.exit(0)
			else:
				choice = int(choice)
				database = databases[choice-1]
				databaseSelected = True
		except ValueError:
			headerMessage("Error : " + choice + " not a valid input !")

def choosePlugin():
	pluginSelected = False
	while not pluginSelected :	
		try:				
			clear_screen()
			found = False
			printMenuStrip()
			print "Available plugins"
			printMenuStrip()
			for plug in plugins:
				print plug["id"] + " : " + plug["type"].capitalize() + " - " + plug["name"].upper()
				found = True
			if not found:
				print "No plugins found for this version !"
			print "X : NO PLUGINS"
			printMenuStrip()
			print "0 : QUIT APP"
			printMenuStrip()
			choice = raw_input("You can select a plugin -> #")
			if choice == '0':
				headerMessage("Bye, see you next time !")
				sys.exit(0)
			else:
				choice = int(choice)
				plugin = plugins[choice-1]
				pluginSelected = True
		except ValueError:
			headerMessage("Error : " + choice + " not a valid input !")

def mainMenu():
	while True:	
		clear_screen()
		printResponseStrip()
		print "-> NQI Build Tool V0.1"
		printResponseStrip()
		print " 1 : Compile application or plugin"
		print " 2 : Deploy plugin"
		print " 3 : Change application database"
		printResponseStrip()
		print " 0 : Exit"
		printResponseStrip()

def headerMessage(msg):
	clear_screen()
	printResponseStrip()
	print "->  " + msg
	printResponseStrip()

def show_variables():
	print "Selected application : " + application["name"]
	print "Selected database : " + database["name"]
	print "plugin selected " + plugin["name"]

#mainMenu()

#while True:
#	chooseApplication()
#	chooseDatabase()
#	choosePlugin()
#	clear_screen()
#	show_variables()
#	
#	#if cmd_mvn_cln_inst(version["nqi_dir"]):
#	if cmd_cp_database_file(application["nqi_dir"], database["file"]):
#		print "Everything all right !"
#	else:
#		print "Not everthing all right !"
#	raw_input("Is it ok ? #")

load_plugins() #don't remove !
choosePlugin()
