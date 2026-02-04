Yes, your idea of using a Patch Struct combined with struct tags is a very solid pattern in Go, especially when you want to avoid the heaviness of an ORM but need more flexibility than raw SQL strings.
To solve the "Three-State Problem" (No Update, Update to Null, Update to Value) while effectively using sqlx and go-ora, you need a combination of Pointers to Nullable Types and a lightweight Dynamic Query Builder.
Here is the breakdown of why this works and how to implement it.
The Logic: Solving the Three States
The standard Go types are not enough. You need to combine pointers with sql nullable types (or generic equivalents) to express all three intentions:
| State | Struct Field Type | Value in Struct |
|---|---|---|
| 1. Non-Update | Pointer (*T) | nil (The field is ignored during SQL generation) |
| 2. Update to Null | *sql.NullString | &sql.NullString{Valid: false} |
| 3. Update to Value | *sql.NullString | &sql.NullString{Valid: true, String: "val"} |
The Solution: Patch Struct + Reflection
You can create a helper function that reads your struct tags and dynamically generates the UPDATE ... SET clause, including only the non-nil fields.
1. Define Your Patch Struct
Use pointers to sql types (like sql.NullString, sql.NullInt64) or your own custom types.
import (
    "database/sql"
    "github.com/jmoiron/sqlx"
)

// UserPatch represents the fields that CAN be updated.
// We use pointers so we can distinguish "missing" (nil) from "empty" or "null".
type UserPatch struct {
    ID    int             `db:"user_id"` // PK, usually required
    Name  *string         `db:"user_name"`
    Email *sql.NullString `db:"email"`   // Use NullString if DB column allows NULL
    Age   *int            `db:"age"`
}

> Note: For Name, I used *string. This supports "No Update" (nil) and "Update to Value" ("params"). It does not support "Update to NULL" (because a string pointer can't hold a null value distinct from nil pointer). Use *sql.NullString if the DB column is nullable.
> 
2. The Dynamic Query Builder
This function uses Go's reflect package to look at the struct, find which fields are not nil, and build the SQL query string for sqlx.
import (
    "fmt"
    "reflect"
    "strings"
)

// BuildUpdateQuery generates an UPDATE statement dynamically based on non-nil struct fields.
func BuildUpdateQuery(tableName string, pkCol string, patch interface{}) (string, error) {
    v := reflect.ValueOf(patch)
    t := reflect.TypeOf(patch)

    if v.Kind() == reflect.Ptr {
        v = v.Elem()
        t = t.Elem()
    }

    var setClauses []string
    
    // Iterate over all fields in the struct
    for i := 0; i < v.NumField(); i++ {
        fieldVal := v.Field(i)
        fieldType := t.Field(i)
        
        // Get the "db" tag
        dbTag := fieldType.Tag.Get("db")
        if dbTag == "" || dbTag == pkCol {
            continue // Skip fields without tags or the Primary Key (we don't update PK usually)
        }

        // Check if the field is a pointer and if it is NOT nil
        // If it's not a pointer, we assume it's always updated (be careful here)
        if fieldVal.Kind() == reflect.Ptr && !fieldVal.IsNil() {
            // Add to set clause: "column_name = :column_name"
            setClauses = append(setClauses, fmt.Sprintf("%s = :%s", dbTag, dbTag))
        }
    }

    if len(setClauses) == 0 {
        return "", fmt.Errorf("no fields to update")
    }

    query := fmt.Sprintf("UPDATE %s SET %s WHERE %s = :%s", 
        tableName, 
        strings.Join(setClauses, ", "), 
        pkCol, 
        pkCol,
    )

    return query, nil
}

3. Putting it together
Here is how you use it in your handler or repository layer.
func UpdateUser(db *sqlx.DB, patch UserPatch) error {
    // 1. Generate the dynamic SQL
    // We only update columns where the pointer in 'patch' is not nil
    query, err := BuildUpdateQuery("users", "user_id", patch)
    if err != nil {
        return err
    }

    // Example Query Generated: 
    // "UPDATE users SET email = :email, age = :age WHERE user_id = :user_id"
    // Note: 'user_name' is skipped if patch.Name is nil

    // 2. Execute using sqlx.NamedExec
    // sqlx maps the struct fields to the :named parameters automatically
    _, err = db.NamedExec(query, patch)
    if err != nil {
        return err
    }

    return nil
}

Why this works for you
 * Unified Column Names: You define the column name once in the db struct tag.
 * No Hardcoding: You don't write SET email = :email manually in every function.
 * Handles 3 States:
   * No Update: Keep the pointer nil. The builder sees IsNil() and excludes it from the SET string.
   * Update to Null: Set the pointer to a valid sql.NullString where Valid: false. The builder includes it in SQL, and sqlx sends NULL to Oracle.
   * Update: Set the pointer to a value.
A Caveat on sql.NullString
sql.NullString is a bit verbose to initialize: &sql.NullString{String: "val", Valid: true}.
You might want a tiny helper generic or function to make your calling code cleaner:
func ToNullString(s string) *sql.NullString {
    return &sql.NullString{String: s, Valid: true}
}

func ToNullStringNull() *sql.NullString {
    return &sql.NullString{Valid: false}
}

Comparison
| Feature | sql.Null* (Standard) | Pointer to Basic (*string) | Pointer to Null (*sql.Null*) |
|---|---|---|---|
| "No Update" | ❌ (Cannot detect missing) | ✅ (nil pointer) | ✅ (nil pointer) |
| "Set NULL" | ✅ (Valid: false) | ❌ (Ambiguous) | ✅ (Valid: false) |
| "Set Value" | ✅ | ✅ | ✅ |
| Verdict | Good for SELECT, bad for PATCH | Good for required fields | Best for PATCH updates |
Would you like me to show you how to write a generic Set[T] type so you don't have to use sql.NullString explicitly?
