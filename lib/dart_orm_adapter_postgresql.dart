library dart_orm_adapter_postgresql;

import 'package:dart_orm/dart_orm.dart';
import 'package:postgresql/postgresql.dart' as psql_connector;
import 'dart:async';
import 'package:logging/logging.dart';


class PostgresqlDBAdapter extends SQLAdapter with DBAdapter {
  final Logger log = new Logger('DartORM.PostgreSQLDBAdapter');

  String _connectionString;

  PostgresqlDBAdapter(String connectionString) {
    _connectionString = connectionString;
  }

  Future connect() async {
    this.connection = await psql_connector.connect(this._connectionString);
  }

  Future select(Select select) async {
    try {
      var result = await super.select(select);
      return result;
    } on psql_connector.PostgresqlException catch(e){
      switch (e.serverMessage.code) {
        case '42P01':
          throw new TableNotExistException();
          break;
        case '42703':
          throw new ColumnNotExistException();
          break;
      }

      throw new UnknownAdapterException(e);
    }
  }

  Future<int> insert(Insert insert) async {
    String sqlQueryString = PostgresqlDBAdapter.constructInsertSql(insert);

    log.finest('Insert: ' + sqlQueryString);

    var result = await connection.query(sqlQueryString).toList();
    if(result.length > 0){
      // if we have any results, here will be returned new primary key
      // of the inserted row
      return result[0][0];
    }

    log.finest('Results:');
    log.finest(result);

    // if model does'nt have primary key we simply return 0
    return 0;
  }

  /**
   * INSERT sql statement constructor.
   */
  static String constructInsertSql(Insert insert) {
    String sql = SQLAdapter.constructInsertSql(insert);

    Field primaryKeyField = insert.table.getPrimaryKeyField();
    if(primaryKeyField != null) {
      var primaryKeyName = SQL.camelCaseToUnderscore(primaryKeyField.fieldName);
      sql += '\nRETURNING ${primaryKeyName}';
    }

    return sql;
  }

  String convertDartType(Field field) {
    String dbTypeName = super.convertDartType(field);

    if(dbTypeName.length < 1){
      switch (field.propertyTypeName) {
        case 'DateTime':
          dbTypeName = 'timestamp without time zone';
          break;
      }
    }

    return dbTypeName;
  }

  String getConstraintsSql(Table table) {
    return '';
  }
}