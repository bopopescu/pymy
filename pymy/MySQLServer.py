import pymysql

class MySQLServer:

    connection = None

    def __init__(self, host="localhost", port=3306, user="", password="", db="test", charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor):

        self.connection = pymysql.connect(host='localhost',
                                         user='user',
                                         password='passwd',
                                         db='db',
                                         charset='utf8mb4',
                                         cursorclass=pymysql.cursors.DictCursor)

    def execute_mysql_query(self, connection, query):
        with connection.cursor() as cursor:
            cursor.execute(query)
            return cursor.fetchall()

    def query_global_status(self, connection, VARIABLE_NAME):
        """
        Returns a single value from the information_schema.GLOBAL_STATUS table
        :param VARIABLE_NAME:
        :return:
        """
        sql = "SELECT * FROM information_schema.GLOBAL_STATUS WHERE VARIABLE_NAME=%s"
        with connection.cursor() as cursor:
            cursor.execute(sql, VARIABLE_NAME)
            result = cursor.fetchone()
            return result['VARIABLE_VALUE']

    def query_global_variables(self, connection, VARIABLE_NAME):
        """
        Returns a single value from the information_schema.GLOBAL_VARIABLES table
        :param VARIABLE_NAME:
        :return:
        """
        sql = "SELECT * FROM information_schema.GLOBAL_VARIABLES WHERE VARIABLE_NAME=%s"
        with connection.cursor() as cursor:
            cursor.execute(sql, VARIABLE_NAME)
            result = cursor.fetchone()
            return result['VARIABLE_VALUE']

    def show_slave_status(self, connection):
        sql = "SHOW SLAVE STATUS"
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return result

    def show_databases(self, connection):
        sql = "SHOW DATABASES"
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return result

    def show_tables(self, connection, database):
        sql = "SHOW TABLES"
        connection.select_db(database)
        with connection.cursor as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return result

    def show_processlist(self, connection, show_full_processlist=False):
        sql = "SHOW PROCESSLIST"
        if show_full_processlist:
            sql="SHOW FULL PROCESSLIST"
        with connection.cursor as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return result
