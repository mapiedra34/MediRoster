package com.example.mediroster;

import android.app.AlertDialog;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.GridLayout;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;

public class CheckInPage extends AppCompatActivity {

    private UserDatabaseHelper dbHelper;
    private GridLayout checkboxGrid;
    private ArrayList<CheckBox> checkBoxes = new ArrayList<>();
    private HashMap<CheckBox, String> checkboxToUsernameMap = new HashMap<>();
    private String today;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_check_in);

        dbHelper = new UserDatabaseHelper(this);
        checkboxGrid = findViewById(R.id.checkbox_grid);
        Button saveBtn = findViewById(R.id.save_btn);

        today = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(new Date());

        // Load who is already checked in (if any)
        Cursor presenceCursor = dbHelper.getPresentNurses(today);
        HashMap<String, Boolean> presentMap = new HashMap<>();
        while (presenceCursor.moveToNext()) {
            presentMap.put(presenceCursor.getString(0), true);
        }
        presenceCursor.close();

        // Load all nurses
        Cursor cursor = dbHelper.getAllNurses();
        while (cursor.moveToNext()) {
            String username = cursor.getString(cursor.getColumnIndexOrThrow("username"));
            String displayName = cursor.getString(cursor.getColumnIndexOrThrow("display_name"));

            CheckBox checkBox = new CheckBox(this);
            checkBox.setText(displayName);
            checkBox.setChecked(true); // Default to checked

            // Override default if saved presence exists
            if (!presentMap.isEmpty()) {
                checkBox.setChecked(presentMap.containsKey(username));
            }

            checkboxGrid.addView(checkBox);
            checkBoxes.add(checkBox);
            checkboxToUsernameMap.put(checkBox, username);
        }
        cursor.close();

        saveBtn.setOnClickListener(v -> {
            saveAttendance();

            new AlertDialog.Builder(this)
                    .setTitle("Reassign Cases")
                    .setMessage("Would you like to reassign cases based on the updated staff check-in?")
                    .setPositiveButton("Yes", (dialog, which) -> {
                        dbHelper.reassignAllCases(today);
                        Toast.makeText(this, "Cases reassigned based on updated staff", Toast.LENGTH_SHORT).show();
                    })
                    .setNegativeButton("No", (dialog, which) -> {
                        Toast.makeText(this, "Attendance saved", Toast.LENGTH_SHORT).show();
                    })
                    .show();
        });
    }

    private void saveAttendance() {
        dbHelper.clearTodayPresence(today);
        for (CheckBox cb : checkBoxes) {
            if (cb.isChecked()) {
                String username = checkboxToUsernameMap.get(cb);
                dbHelper.markNursePresent(username, today);
            }
        }
    }
}
