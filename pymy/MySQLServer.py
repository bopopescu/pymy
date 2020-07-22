import pymysql

class MySQLServer:

    connection = None

    def __init__(self, host, port, user, password, db="test", charset="utf8mb4"):

        self.connection = pymysql.connect(host=host,
                                          port=port,
                                         user=user,
                                         passwd=password,
                                         db=db,
                                         charset=charset)

    def execute_mysql_query(self, connection, query):
        """
        Execute the sql provided and return a pymysql tuple set
        :param connection:
        :param query:
        :return:
        """
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
            return result[1]

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
            return result[1]

    def show_subordinate_status(self, connection):
        """
        Execute the "SHOW SLAVE STATUS" command
        :param connection:
        :return: TODO This should return a dictionary
        """
        sql = "SHOW SLAVE STATUS"
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return result

    def show_main_status(self, connection):
        """
        Execute the "SHOW MASTER STATUS" command
        :param connection:
        :return: A dictionary
        """
        sql = "SHOW MASTER STATUS"
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            result = { "file": result[0][0],
                       "position": int(result[0][1]),
                       "binlog_do_db": result[0][2],
                       "binlog_ignore_db": result[0][3]}
            return result

    def show_databases(self, connection):
        """
        Execute the "SHOW DATABASES" command
        :param connection
        :return: A list of database names
        """
        sql = "SHOW DATABASES"
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = [row[0] for row in cursor.fetchall()]
            return result

    def show_tables(self, connection, database):
        """
        Execute the "SHOW TABLES" command for the given database
        :param connection:
        :param database:
        :return: A list of table names for the
        """
        sql = "SHOW TABLES"
        connection.select_db(database)
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = [row[0] for row in cursor.fetchall()]
            return result

    def show_processlist(self, connection, show_full_processlist=False):
        """
        Execute the "SHOW PROCESSLIST" or "SHOW FULL PROCESSLIST" command
        :param connection:
        :param show_full_processlist:
        :return: A list of dictionaries
        """
        if show_full_processlist:
            sql="SHOW FULL PROCESSLIST"
        else:
            sql = "SHOW PROCESSLIST"
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = []
            for row in cursor.fetchall():
                result.append({"id": int(row[0]),
                               "user": row[1],
                               "host": row[2],
                               "db": row[3],
                               "command": row[4],
                               "time": int(row[5]),
                               "state": row[6],
                               "info": row[7],
                               "progress": float(row[8])})
            return result
