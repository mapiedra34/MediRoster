package com.example.mediroster;

import android.app.DatePickerDialog;
import android.database.Cursor;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;

public class AddCasePage extends AppCompatActivity {

    private EditText caseDescription, dateInput;
    private Spinner startTimeSpinner, durationSpinner, shiftSpinner, requiredNursesSpinner, operationSpinner;
    private Button addCaseBtn;

    private UserDatabaseHelper dbHelper;
    private final String[] timeSlots = generateHourlySlots();
    private final String[] nurseOptions = {"1", "2", "3", "4", "5"};
    private final String[] durations = {"1", "2", "3", "4", "6", "8", "12"};
    private final HashMap<String, Integer> shiftMap = new HashMap<>();

    private static String[] generateHourlySlots() {
        String[] slots = new String[24];
        for (int i = 0; i < 24; i++) {
            slots[i] = String.format(Locale.US, "%02d:00", i);
        }
        return slots;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_case);

        dbHelper = new UserDatabaseHelper(this);

        caseDescription = findViewById(R.id.case_description);
        dateInput = findViewById(R.id.case_date_input);
        startTimeSpinner = findViewById(R.id.time_slot_spinner);
        durationSpinner = findViewById(R.id.duration_spinner);
        shiftSpinner = findViewById(R.id.shift_spinner);
        addCaseBtn = findViewById(R.id.add_case_btn);
        operationSpinner = findViewById(R.id.operation_spinner);

        loadShiftsIntoSpinner();
        loadOperationsIntoSpinner();

        dateInput.setOnClickListener(v -> showDatePicker());

        startTimeSpinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, timeSlots));
        durationSpinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, durations));

        addCaseBtn.setOnClickListener(v -> addCase());
    }
    private boolean isWithinShiftBounds(String caseStart, String caseEnd, String shiftStart, String shiftEnd) {
        try {
            int cs = Integer.parseInt(caseStart.split(":")[0]);
            int ce = Integer.parseInt(caseEnd.split(":")[0]);
            int ss = Integer.parseInt(shiftStart.split(":")[0]);
            int se = Integer.parseInt(shiftEnd.split(":")[0]);
            return cs >= ss && ce <= se;
        } catch (Exception e) {
            return false; // fallback if parsing fails
        }
    }
    private void showDatePicker() { //pop up calendar
        final Calendar calendar = Calendar.getInstance();
        DatePickerDialog dialog = new DatePickerDialog(this, (DatePicker view, int year, int month, int day) -> {
            Calendar selected = Calendar.getInstance();
            selected.set(year, month, day);
            String date = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(selected.getTime());
            dateInput.setText(date);
        }, calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH));
        dialog.show();
    }
    private void loadOperationsIntoSpinner() { //operations preload for drop down
        Cursor cursor = dbHelper.getAllOperations();
        ArrayList<String> operations = new ArrayList<>();
        while (cursor.moveToNext()) {
            operations.add(cursor.getString(cursor.getColumnIndexOrThrow("operation_name")));
        }
        cursor.close();

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, operations);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        operationSpinner.setAdapter(adapter);
    }

    private void loadShiftsIntoSpinner() { //shifts go into a drop down
        Cursor cursor = dbHelper.getAllShifts();
        ArrayList<String> shiftLabels = new ArrayList<>();
        shiftMap.clear();

        while (cursor.moveToNext()) {
            int id = cursor.getInt(cursor.getColumnIndexOrThrow("shift_id"));
            String label = id + ": " +
                    cursor.getString(cursor.getColumnIndexOrThrow("date")) + " " +
                    cursor.getString(cursor.getColumnIndexOrThrow("start_time")) + " - " +
                    cursor.getString(cursor.getColumnIndexOrThrow("end_time"));
            shiftLabels.add(label);
            shiftMap.put(label, id);
        }
        cursor.close();

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, shiftLabels);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        shiftSpinner.setAdapter(adapter);
    }
    private String computeEndTime(String startTime, int durationHours) { //determines what time the case will end
        try {
            String[] parts = startTime.split(":");
            int startHour = Integer.parseInt(parts[0]);
            int endHour = (startHour + durationHours) % 24;
            return String.format(Locale.US, "%02d:00", endHour);
        } catch (Exception e) {
            e.printStackTrace();
            return "00:00"; // fallback
        }
    }
    private void addCase() { //create new case
        String description = caseDescription.getText().toString().trim();
        String date = dateInput.getText().toString().trim();
        String startTime = startTimeSpinner.getSelectedItem().toString();
        String durationStr = durationSpinner.getSelectedItem().toString();
        String selectedShiftLabel = (String) shiftSpinner.getSelectedItem();
        String selectedOperation = operationSpinner.getSelectedItem().toString();

        if (description.isEmpty() || date.isEmpty() || selectedShiftLabel == null) {
            Toast.makeText(this, "Please fill in all fields", Toast.LENGTH_SHORT).show();
            return;
        }

        int duration;
        try {
            duration = Integer.parseInt(durationStr);
        } catch (NumberFormatException e) {
            Toast.makeText(this, "Invalid duration", Toast.LENGTH_SHORT).show();
            return;
        }

        String endTime = computeEndTime(startTime, duration);
        Integer shiftId = shiftMap.get(selectedShiftLabel);

        // Validate case timing is within shift bounds
        Cursor shiftCursor = dbHelper.getShiftById(shiftId);
        if (shiftCursor.moveToFirst()) {
            String shiftStart = shiftCursor.getString(shiftCursor.getColumnIndexOrThrow("start_time"));
            String shiftEnd = shiftCursor.getString(shiftCursor.getColumnIndexOrThrow("end_time"));

            if (!isWithinShiftBounds(startTime, endTime, shiftStart, shiftEnd)) {
                Toast.makeText(this, "Case must be within shift time (" + shiftStart + " - " + shiftEnd + ")", Toast.LENGTH_LONG).show();
                shiftCursor.close();
                return;
            }
        }
        shiftCursor.close();

        if (shiftId == null) {
            Toast.makeText(this, "Please select a valid shift", Toast.LENGTH_SHORT).show();
            return;
        }

        long caseId = dbHelper.addCase(description, shiftId, startTime, endTime, selectedOperation);
        if (caseId != -1) { //adds case with time
            dbHelper.autoAssignNursesToCase((int) caseId, date, startTime, endTime);
            Toast.makeText(this, "Case created and nurses assigned", Toast.LENGTH_SHORT).show();
            finish();
        } else {
            Toast.makeText(this, "Failed to create case", Toast.LENGTH_SHORT).show();
        }
    }

}
