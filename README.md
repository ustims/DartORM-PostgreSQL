PostgreSQL adapter for DartORM.
===============================

https://github.com/ustims/DartORM


Usage example
-------------

```dart
import 'package:dart_orm/dart_orm.dart';
import 'package:dart_orm_adapter_postgresql/dart_orm_adapter_postgresql.dart';

...

String psqlUser = 'dart_orm_test_user';
String psqlPassword = 'dart_orm_test_user';
String psqlDBName = 'dart_orm_test';

PostgresqlDBAdapter postgresqlAdapter = new PostgresqlDBAdapter(
'postgres://$psqlUser:$psqlPassword@localhost:5432/$psqlDBName');
await postgresqlAdapter.connect();

ORM.Model.ormAdapter = postgresqlAdapter;
```