import sqlite3

try:
    sqliteConnection = sqlite3.connect('files/cap.db')
    cursor = sqliteConnection.cursor()
    print("Database Successfully connected to SQLite\n")
except sqlite3.Error as error:
    print("Error while connecting to sqlite  ", error) 

def viewtemplates():
    try:
        sqlite_select_query = """SELECT * from Templates;"""
        cursor.execute(sqlite_select_query)
        records = cursor.fetchall()
        print("Total templates are:  ", len(records))
        print("\n")
        for row in records:
            print("TEMP_Id: ", row[0])
            print("Name_of_template: ", row[1])
            print("capabilities_of_template: ")
            data_list = row[2].split (",")
            for no in data_list:
                sqlite_select_query_2 = """SELECT * from Capabilities where CAP_ID = ?;"""
                cursor.execute(sqlite_select_query_2,no)
                records_2 = cursor.fetchall()
                print("\n")
                for rows in records_2:
                    print("CAP_Id: ", rows[0])
                    print("Name_of_capability: ", rows[1])
                    print("description_of_capability: ", rows[2])
            print("-----------------\n")

    except sqlite3.Error as error:
        print("Failed to read data from sqlite table", error)

def view_cap():
    try:
        sqlite_select_query_2 = """SELECT * from capabilities;"""
        cursor.execute(sqlite_select_query_2)
        records_2 = cursor.fetchall()
        for rows in records_2:
            print("CAP_Id: ", rows[0])
            print("Name_of_capability: ", rows[1])
            print("description_of_capability: ", rows[2])
            print("\n")
            
    except sqlite3.Error as error:
        print("Failed to read data from sqlite table", error)

def insertVaribleIntoTemp(Name_of_template,Capabilities_of_template):   
        try:
            sqlite_insert_with_param = """INSERT INTO Templates(Name_of_template,Capabilities_of_template) VALUES (?, ?);"""
            data_tuple = (Name_of_template,Capabilities_of_template)
            cursor.execute(sqlite_insert_with_param, data_tuple)
            sqliteConnection.commit()

        except sqlite3.Error as error:
            print("Error while inserting to table templates", error)

def insertVaribleIntoCap(Name_of_cap,des_cap):
    try:
        sqlite_insert = """INSERT INTO Capabilities(Name_of_capabilities,Description_of_capabilities) VALUES (?, ?);"""
        data_tuple = (Name_of_cap,des_cap)
        cursor.execute(sqlite_insert, data_tuple)
        sqliteConnection.commit()

    except sqlite3.Error as error:
        print("Error while inserting to table templates", error)

def user_input():
    print("OPTIONS:\nPress 0 to see existing capabilities\nPress 1 to add a new capability\nPress 2 to see existing templates\nPress 3 to add a new template\n")
    opt = input()
    if opt == "0" :
        view_cap()
    elif opt == "1" :              
        cap_no = input("Creating new capabilities\nHow many capability to be created: ")
        capability_no = int(cap_no)
        for caps in range(capability_no):
            cap_name = input("Name for capability: ")
            cap_desp = input("Describe the capability: ")
            insertVaribleIntoCap(cap_name,cap_desp)
    elif opt == "2" :
        viewtemplates()
    elif opt == "3" :              
        temp_no = input("Creating templates\nHow many templates to be created: ")
        template_no = int(temp_no)
        for x in range(template_no):
            temp_name = input("Name for template: ")
            view_cap()
            cap_chosen= input("Choose capabilities from above and type their respective CAP_ID: ")
            insertVaribleIntoTemp(temp_name,cap_chosen)
    else:
        print("Type a valid option")

while True:
    user_input() 
    i = input("To exit press 'E' or to continue press any other key\n")  
    if(i == "E"):  
        break 

if cursor:
    cursor.close()
if sqliteConnection:
    sqliteConnection.close()
    print("The SQLite connection is now closed")
