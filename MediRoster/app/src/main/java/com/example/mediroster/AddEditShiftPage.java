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

public class AddEditShiftPage extends AppCompatActivity {

    private EditText dateInput;
    private Button addShiftBtn, deleteShiftBtn;
    private Spinner shiftListSpinner;

    private UserDatabaseHelper dbHelper;
    private HashMap<String, Integer> shiftMap = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_edit_shift);

        dbHelper = new UserDatabaseHelper(this);

        dateInput = findViewById(R.id.shift_date);
        addShiftBtn = findViewById(R.id.add_shift_btn);
        deleteShiftBtn = findViewById(R.id.delete_shift_btn);
        shiftListSpinner = findViewById(R.id.shift_list_spinner);

        // Make date picker work
        dateInput.setOnClickListener(v -> showDatePicker());

        loadShifts();

        addShiftBtn.setOnClickListener(v -> {
            String date = dateInput.getText().toString().trim();
            String start = "06:00";
            String end = "18:00";

            if (date.isEmpty()) {
                Toast.makeText(this, "Please select a date", Toast.LENGTH_SHORT).show();
                return;
            }

            if (dbHelper.shiftOverlaps(date, start, end)) {
                Toast.makeText(this, "Shift overlaps with an existing shift!", Toast.LENGTH_LONG).show();
                return;
            }

            boolean inserted = dbHelper.insertShift(date, start, end);
            if (inserted) {
                Toast.makeText(this, "Shift added", Toast.LENGTH_SHORT).show();
                loadShifts();
            } else {
                Toast.makeText(this, "Failed to add shift", Toast.LENGTH_SHORT).show();
            }
        });

        deleteShiftBtn.setOnClickListener(v -> {
            String label = (String) shiftListSpinner.getSelectedItem();
            Integer shiftId = shiftMap.get(label);
            if (shiftId != null) {
                boolean deleted = dbHelper.deleteShift(shiftId);
                if (deleted) {
                    Toast.makeText(this, "Shift deleted", Toast.LENGTH_SHORT).show();
                    loadShifts();
                } else {
                    Toast.makeText(this, "Cannot delete shift in use", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void showDatePicker() { // pop up calendar
        final Calendar calendar = Calendar.getInstance();
        DatePickerDialog dialog = new DatePickerDialog(this, (DatePicker view, int year, int month, int dayOfMonth) -> {
            Calendar selected = Calendar.getInstance();
            selected.set(year, month, dayOfMonth);
            String formatted = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(selected.getTime());
            dateInput.setText(formatted);
        }, calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH));
        dialog.show();
    }

    private void loadShifts() {
        Cursor cursor = dbHelper.getAllShifts();
        ArrayList<String> labels = new ArrayList<>();
        shiftMap.clear();

        while (cursor.moveToNext()) {
            int id = cursor.getInt(cursor.getColumnIndexOrThrow("shift_id"));
            String label = id + ": " +
                    cursor.getString(cursor.getColumnIndexOrThrow("date")) + " " +
                    cursor.getString(cursor.getColumnIndexOrThrow("start_time")) + "-" +
                    cursor.getString(cursor.getColumnIndexOrThrow("end_time"));
            shiftMap.put(label, id);
            labels.add(label);
        }
        cursor.close();

        shiftListSpinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, labels));
    }
}
