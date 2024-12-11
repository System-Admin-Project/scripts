import csv
import random
import os
from datetime import datetime, timedelta

# Predefined list of student names
students = [
    "John Doe", "Jane Smith", "Alice Johnson", "Bob Brown", "Charlie Davis",
    "Emily Clark", "Michael Miller", "Sarah Wilson", "James Taylor", "Laura Martin",
    "David Anderson", "Sophia Moore", "Daniel Harris", "Olivia Thompson", "Matthew White",
    "Isabella Lewis", "Andrew Walker", "Emma Hall", "Joseph King", "Mia Scott",
    "Christopher Green", "Amelia Adams", "Joshua Nelson", "Elizabeth Baker", "Ryan Carter",
    "Grace Mitchell", "Lucas Perez", "Chloe Roberts", "Ethan Turner", "Abigail Phillips"
]

# Generate matricules in the format FE22Axxx
matricules = [f"FE22A{str(i+1).zfill(3)}" for i in range(len(students))]

# List of courses
courses = ["CEF401", "CEF473", "CEF405", "CEF415", "CEF451","CEF427"]

# Function to generate random attendance
def generate_random_attendance():
    return "present" if random.choice([True, False]) else "absent"

# Function to generate dates for two weeks
def generate_class_dates(start_date, course_schedule):
    dates = []
    for i in range(3):  # Two weeks
        for day in course_schedule:
            class_date = start_date + timedelta(days=(i * 7 + day - 1))
            dates.append(class_date.strftime("%Y-%m-%d"))
    return dates

def main():
    # Define the base folder path
    base_folder = "../data/FET/Level400/SoftwareEng/Attendance"

    # Define the course schedule (Monday = 1, ..., Friday = 5)
    course_schedule = [1, 3]  # Classes held on Monday and Wednesday

    # Start date for the first week
    start_date = datetime.strptime("2024-12-09", "%Y-%m-%d")  # Example start date

    # Generate class dates for two weeks
    class_dates = generate_class_dates(start_date, course_schedule)

    try:
        for course_name in courses:
            # Create course folder
            course_folder = os.path.join(base_folder, course_name)
            os.makedirs(course_folder, exist_ok=True)

            for class_date in class_dates:
                # Define the output file path
                output_file = os.path.join(course_folder, f"{course_name}_attendance_{class_date}.csv")

                # Create the CSV file and add header
                with open(output_file, mode='w', newline='') as file:
                    writer = csv.writer(file)
                    writer.writerow(["Student Name", "Matricule", "Attendance"])

                    # Generate random attendance for each student
                    for student, matricule in zip(students, matricules):
                        attendance = generate_random_attendance()
                        writer.writerow([student, matricule, attendance])

                print(f"Random attendance data saved to {output_file}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
