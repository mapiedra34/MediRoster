package com.example.mediroster;

import android.database.Cursor;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import java.util.ArrayList;
import java.util.HashMap;

public class EditCasePage extends AppCompatActivity {

    private Spinner caseSpinner, shiftSpinner;
    private EditText descriptionInput, requiredNursesInput;
    private Button updateCaseBtn;
    private Integer caseId;
    private UserDatabaseHelper dbHelper;

    private HashMap<String, Integer> caseMap = new HashMap<>();
    private HashMap<String, Integer> shiftMap = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_case);

        dbHelper = new UserDatabaseHelper(this);

        caseSpinner = findViewById(R.id.case_spinner);
        shiftSpinner = findViewById(R.id.edit_shift_spinner);
        descriptionInput = findViewById(R.id.edit_case_description);
        requiredNursesInput = findViewById(R.id.edit_required_nurses);
        updateCaseBtn = findViewById(R.id.update_case_btn);

        loadCases();
        loadShifts();

        caseSpinner.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(android.widget.AdapterView<?> parent, android.view.View view, int position, long id) {
                String selected = (String) parent.getItemAtPosition(position);
                caseId = caseMap.get(selected);
                if (caseId != null) {
                    loadCaseDetails(caseId);
                }
            }

            @Override
            public void onNothingSelected(android.widget.AdapterView<?> parent) {}
        });

        updateCaseBtn.setOnClickListener(v -> {
            String caseLabel = (String) caseSpinner.getSelectedItem();
            Integer caseId = caseMap.get(caseLabel);
            String shiftLabel = (String) shiftSpinner.getSelectedItem();
            Integer shiftId = shiftMap.get(shiftLabel);

            String desc = descriptionInput.getText().toString().trim();
            String nurseStr = requiredNursesInput.getText().toString().trim();

            if (caseId == null || shiftId == null || desc.isEmpty() || nurseStr.isEmpty()) {
                Toast.makeText(this, "Please complete all fields", Toast.LENGTH_SHORT).show();
                return;
            }

            int nurses;
            try {
                nurses = Integer.parseInt(nurseStr);
            } catch (NumberFormatException e) {
                Toast.makeText(this, "Invalid nurse count", Toast.LENGTH_SHORT).show();
                return;
            }

            boolean updated = dbHelper.updateCase(caseId, desc, shiftId, nurses);
            if (updated) {
                Toast.makeText(this, "Case updated", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "Failed to update", Toast.LENGTH_SHORT).show();
            }
        });
        Button deleteBtn = findViewById(R.id.delete_case_btn); //deleted the selected case
        deleteBtn.setOnClickListener(v -> {
            boolean success = dbHelper.deleteCase(caseId);
            if (success) {
                Toast.makeText(this, "Case deleted", Toast.LENGTH_SHORT).show();
                finish(); //goes back to screen
            } else {
                Toast.makeText(this, "Failed to delete case", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void loadCases() {
        Cursor cursor = dbHelper.getAllCases();
        ArrayList<String> labels = new ArrayList<>();
        while (cursor.moveToNext()) {
            int id = cursor.getInt(cursor.getColumnIndexOrThrow("case_id"));
            String desc = cursor.getString(cursor.getColumnIndexOrThrow("description"));
            String label = "ID " + id + ": " + desc;
            caseMap.put(label, id);
            labels.add(label);
        }
        cursor.close();
        caseSpinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, labels));
    }

    private void loadShifts() {
        Cursor cursor = dbHelper.getAllShifts();
        ArrayList<String> labels = new ArrayList<>();
        while (cursor.moveToNext()) {
            int id = cursor.getInt(cursor.getColumnIndexOrThrow("shift_id"));
            String label = id + ": " + cursor.getString(cursor.getColumnIndexOrThrow("date")) +
                    " " + cursor.getString(cursor.getColumnIndexOrThrow("start_time")) +
                    "-" + cursor.getString(cursor.getColumnIndexOrThrow("end_time"));
            shiftMap.put(label, id);
            labels.add(label);
        }
        cursor.close();
        shiftSpinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, labels));
    }

    private void loadCaseDetails(int caseId) {
        Cursor cursor = dbHelper.getCaseById(caseId);
        if (cursor.moveToFirst()) {
            String desc = cursor.getString(cursor.getColumnIndexOrThrow("description"));
            int requiredNurses = cursor.getInt(cursor.getColumnIndexOrThrow("required_nurses"));
            int shiftId = cursor.getInt(cursor.getColumnIndexOrThrow("scheduled_shift_id"));

            descriptionInput.setText(desc);
            requiredNursesInput.setText(String.valueOf(requiredNurses));

            for (String key : shiftMap.keySet()) {
                if (shiftMap.get(key) == shiftId) {
                    shiftSpinner.setSelection(new ArrayList<>(shiftMap.keySet()).indexOf(key));
                    break;
                }
            }
        }
        cursor.close();
    }
}
