package com.example.mediroster;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class UserDatabaseHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "user_db";
    private static final int DATABASE_VERSION = 1;

    public UserDatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override // creating the tables
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE users (" +
                "username TEXT PRIMARY KEY, " +
                "password TEXT, " +
                "role TEXT, " +
                "display_name TEXT)");

        db.execSQL("CREATE TABLE shifts (" +
                "shift_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "date TEXT, " +
                "start_time TEXT, " +
                "end_time TEXT)");

        db.execSQL("CREATE TABLE cases (" +
                "case_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "description TEXT, " +
                "required_nurses INTEGER, " +
                "scheduled_shift_id INTEGER, " +
                "operation TEXT, " +
                "start_time TEXT," +
                "end_time TEXT," +
                "FOREIGN KEY(scheduled_shift_id) REFERENCES shifts(shift_id))");

        db.execSQL("CREATE TABLE assignments (" +
                "assignment_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "case_id INTEGER, " +
                "user_id TEXT, " +
                "FOREIGN KEY(case_id) REFERENCES cases(case_id), " +
                "FOREIGN KEY(user_id) REFERENCES users(username))");

        db.execSQL("CREATE TABLE presence (" +
                "username TEXT, " +
                "date TEXT, " +
                "PRIMARY KEY(username, date), " +
                "FOREIGN KEY(username) REFERENCES users(username))");

        db.execSQL("CREATE TABLE operations (" +
                "operation_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "operation_name TEXT NOT NULL)");

        for (int i = 1; i <= 5; i++) {
            ContentValues admin = new ContentValues();
            admin.put("username", "admin" + i);
            admin.put("password", "adminpass");
            admin.put("role", "admin");
            admin.put("display_name", "Admin " + i);
            db.insert("users", null, admin);
        }

        String[] nurseNames = {"Alex", "Jordan", "Taylor", "Morgan", "Sydney", "Casey", "Riley", "Jamie", "Drew", "Robin",
                "Avery", "Cameron", "Quinn", "Reese", "Skylar", "Hayden", "Peyton", "Logan", "Sawyer", "Blake",
                "Charlie", "Rowan", "Harper", "Dakota", "Kendall"}; //added nurses names for cleaner look

        for (int i = 1; i <= 25; i++) {
            ContentValues nurse = new ContentValues();
            nurse.put("username", "nurse" + i);
            nurse.put("password", "nursepass");
            nurse.put("role", "nurse");
            nurse.put("display_name", nurseNames[i - 1]);
            db.insert("users", null, nurse);
        }

        String[] operations = {"Appendectomy", "Gallbladder Removal", "Knee Replacement", "Hip Replacement", "Hernia Repair",
                "Cesarean Section", "Tonsillectomy", "Mastectomy", "Coronary Bypass", "Cataract Surgery"};

        for (String op : operations) {
            ContentValues opVal = new ContentValues();
            opVal.put("operation_name", op);
            db.insert("operations", null, opVal);
        }
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS presence");
        db.execSQL("DROP TABLE IF EXISTS assignments");
        db.execSQL("DROP TABLE IF EXISTS cases");
        db.execSQL("DROP TABLE IF EXISTS shifts");
        db.execSQL("DROP TABLE IF EXISTS users");
        db.execSQL("DROP TABLE IF EXISTS operations");
        onCreate(db);
    }

    public boolean validateLogin(String username, String password) {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM users WHERE username = ? AND password = ?", new String[]{username, password});
        boolean isValid = cursor.getCount() > 0;
        cursor.close();
        return isValid;
    }

    public String getUserRole(String username, String password) {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT role FROM users WHERE username = ? AND password = ?", new String[]{username, password});
        String role = null;
        if (cursor.moveToFirst()) {
            role = cursor.getString(cursor.getColumnIndexOrThrow("role"));
        }
        cursor.close();
        return role;
    }
    public Cursor getShiftById(int shiftId) {
        return getReadableDatabase().rawQuery("SELECT * FROM shifts WHERE shift_id = ?", new String[]{String.valueOf(shiftId)});
    }
    public Cursor getAssignedCasesWithCaseTimes(String username, String date) {
        return getReadableDatabase().rawQuery(
                "SELECT c.description, c.start_time, c.end_time " +
                        "FROM assignments a " +
                        "JOIN cases c ON a.case_id = c.case_id " +
                        "JOIN shifts s ON c.scheduled_shift_id = s.shift_id " +
                        "WHERE a.user_id = ? AND s.date = ?",
                new String[]{username, date});
    }
    public void reassignAllCases(String date) {
        SQLiteDatabase db = this.getWritableDatabase();

        // Get all cases for today
        Cursor caseCursor = db.rawQuery(
                "SELECT case_id, required_nurses, scheduled_shift_id FROM cases c " +
                        "JOIN shifts s ON c.scheduled_shift_id = s.shift_id WHERE s.date = ?",
                new String[]{date}
        );

        while (caseCursor.moveToNext()) {
            int caseId = caseCursor.getInt(caseCursor.getColumnIndexOrThrow("case_id"));
            int requiredNurses = caseCursor.getInt(caseCursor.getColumnIndexOrThrow("required_nurses"));

            // Remove existing assignments for this case
            db.delete("assignments", "case_id = ?", new String[]{String.valueOf(caseId)});

            // Reassign nurses to the case
            Cursor shiftCursor = db.rawQuery(
                    "SELECT start_time, end_time FROM shifts WHERE shift_id = ?",
                    new String[]{String.valueOf(caseCursor.getInt(caseCursor.getColumnIndexOrThrow("scheduled_shift_id")))}
            );

            if (shiftCursor.moveToFirst()) {
                String start_time = shiftCursor.getString(shiftCursor.getColumnIndexOrThrow("start_time"));
                String end_time = shiftCursor.getString(shiftCursor.getColumnIndexOrThrow("end_time"));
                autoAssignNursesToCase(caseId, date, start_time, end_time);
            }

            shiftCursor.close();
        }

        caseCursor.close();
    }

    public Cursor getAllNurses() {
        return getReadableDatabase().rawQuery("SELECT username, display_name FROM users WHERE role = 'nurse'", null);
    }

    public boolean markNursePresent(String username, String date) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("username", username);
        values.put("date", date);
        return db.insertWithOnConflict("presence", null, values, SQLiteDatabase.CONFLICT_IGNORE) != -1;
    }

    public void clearTodayPresence(String date) {
        getWritableDatabase().delete("presence", "date = ?", new String[]{date});
    }

    public Cursor getPresentNurses(String date) {
        return getReadableDatabase().rawQuery("SELECT username FROM presence WHERE date = ?", new String[]{date});
    }

    public Cursor getAllCases() {
        return getReadableDatabase().rawQuery("SELECT case_id, description FROM cases", null);
    }

    public Cursor getCaseById(int caseId) {
        return getReadableDatabase().rawQuery("SELECT * FROM cases WHERE case_id = ?", new String[]{String.valueOf(caseId)});
    }

    public boolean updateCase(int caseId, String description, int shiftId, int requiredNurses) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("description", description);
        values.put("scheduled_shift_id", shiftId);
        values.put("required_nurses", requiredNurses);
        return db.update("cases", values, "case_id = ?", new String[]{String.valueOf(caseId)}) > 0;
    }

    public long addCase(String description, int shiftId, String startTime, String endTime, String operation) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("description", description);
        values.put("scheduled_shift_id", shiftId);
        values.put("start_time", startTime);
        values.put("end_time", endTime);
        values.put("operation", operation);
        return db.insert("cases", null, values);

    }

    public Cursor getCaseWithShift(int caseId) {
        return getReadableDatabase().rawQuery(
                "SELECT c.description, s.date, s.start_time, s.end_time FROM cases c JOIN shifts s ON c.scheduled_shift_id = s.shift_id WHERE c.case_id = ?",
                new String[]{String.valueOf(caseId)});
    }
    public Cursor getCasesForDate(String date) {
        return getReadableDatabase().rawQuery(
                "SELECT c.case_id, c.description FROM cases c JOIN shifts s ON c.scheduled_shift_id = s.shift_id WHERE s.date = ?",
                new String[]{date});
    }
    public Cursor getCasesForUserOnDate(String username, String date) {
        return getReadableDatabase().rawQuery(
                "SELECT c.case_id, c.description FROM assignments a JOIN cases c ON a.case_id = c.case_id JOIN shifts s ON c.scheduled_shift_id = s.shift_id WHERE a.user_id = ? AND s.date = ?",
                new String[]{username, date});
    }

    public Cursor getAllShifts() {
        return getReadableDatabase().rawQuery("SELECT shift_id, date, start_time, end_time FROM shifts", null);
    }

    public boolean insertShift(String date, String startTime, String endTime) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("date", date);
        values.put("start_time", startTime);
        values.put("end_time", endTime);
        return db.insert("shifts", null, values) != -1;
    }

    public boolean deleteShift(int shiftId) {
        SQLiteDatabase db = this.getWritableDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM cases WHERE scheduled_shift_id = ?", new String[]{String.valueOf(shiftId)});
        boolean inUse = cursor.getCount() > 0;
        cursor.close();
        return !inUse && db.delete("shifts", "shift_id = ?", new String[]{String.valueOf(shiftId)}) > 0;
    }

    public boolean shiftOverlaps(String date, String newStart, String newEnd) {
        Cursor cursor = getReadableDatabase().rawQuery(
                "SELECT * FROM shifts WHERE date = ? AND (? < end_time AND ? > start_time)",
                new String[]{date, newEnd, newStart});
        boolean overlaps = cursor.getCount() > 0;
        cursor.close();
        return overlaps;

    }

    public boolean deleteCase(int caseId) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete("assignments", "case_id = ?", new String[]{String.valueOf(caseId)}); // removes assignments
        return db.delete("cases", "case_id = ?", new String[]{String.valueOf(caseId)}) > 0;
    }

    public Cursor getNursesAssignedToCase(int caseId) {
        return getReadableDatabase().rawQuery(
                "SELECT u.display_name FROM assignments a " +
                        "JOIN users u ON a.user_id = u.username " +
                        "WHERE a.case_id = ?",
                new String[]{String.valueOf(caseId)}
        );
    }
    public Cursor getAllOperations() {
        return getReadableDatabase().rawQuery("SELECT operation_name FROM operations", null);
    }
    public void autoAssignNursesToCase(int caseId, String date, String startTime, String endTime) {
        SQLiteDatabase db = this.getWritableDatabase();

        // All nurses checked in today
        String nurseQuery = "SELECT username FROM users WHERE role = 'nurse' " +
                "AND username IN (SELECT username FROM presence WHERE date = ?)";

        Cursor cursor = db.rawQuery(nurseQuery, new String[]{date});

        if (cursor.moveToFirst()) {
            String nurseUsername = cursor.getString(0);

            // Check if nurse is already assigned to overlapping case
            Cursor overlapCursor = db.rawQuery(
                    "SELECT 1 FROM assignments a " +
                            "JOIN cases c ON a.case_id = c.case_id " +
                            "JOIN shifts s ON c.scheduled_shift_id = s.shift_id " +
                            "WHERE a.user_id = ? AND s.date = ? " +
                            "AND (? < s.end_time AND ? > s.start_time)",
                    new String[]{nurseUsername, date, endTime, startTime}
            );

            boolean isOverlapping = overlapCursor.moveToFirst();
            overlapCursor.close();

            if (!isOverlapping) {
                ContentValues values = new ContentValues();
                values.put("case_id", caseId);
                values.put("user_id", nurseUsername);
                db.insert("assignments", null, values);
            }
        }

        cursor.close();
    }

    public String getDisplayName(String username) {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT display_name FROM users WHERE username = ?", new String[]{username});
        String displayName = username; // fallback to username
        if (cursor.moveToFirst()) {
            displayName = cursor.getString(cursor.getColumnIndexOrThrow("display_name"));
        }
        cursor.close();
        return displayName;
    }

}
