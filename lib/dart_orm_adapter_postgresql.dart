library dart_orm_adapter_postgresql;

import 'package:dart_orm/dart_orm.dart';
import 'package:postgresql/postgresql.dart' as psql_connector;
import 'dart:async';


class PostgresqlDBAdapter extends SQLAdapter with DBAdapter {
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

      throw new UnknownAdapterException();
    }
  }
}