
import csv 
import random 
from datetime import datetime

students = ['Abanda Sergio', 'Abilatezie Vin-Wilson ', 'Abongwa Caleb Nforngwa', 'Afayi Munsfu ObaseNgala',
 'Agbor Emmanuel Nchenge', 'Agyingi Rachel Mifor', 'Ajim Neville Bemsibom', 'Akenji Faith Sirri', 'Ako Ruth Achere', 'Ambassa Lise-Asrid', 'Anne Benita', 'Arrey Abunaw Regina', 'Arrey-Tabot Pascaline', 'Atankeu Tchakoute Ange', 'Atiku Boris-Ben', 'AvNyehbeuhkohn Ezekiel Hosana', 'Awa Eric Angelo', 'Ayuk Nestor Eyong', 'Beh Chu Nelson'] 
matricules = ['FE22A131', 'FE22A132', 'FE22A133', 'FE22A136', 
        'FE22A138', 'FE22A140', 'FE22A141', 'FE22A142', 'FE22A144', 'FE22A46', 'FE22A149', 'FE22A152', 'FE22A151', 'FE22A158', 'FE22A159', 'FE22A160', 'FE22A162', 'FE22A164', 'FE22A170'] 

def gen_rand_att():
	return "present" if random.choice([True, False]) else "absent"

def main():

	course_name = input("Enter course name: ")
	date = input("Enter date (YYYY-MM-DD): " )

	output_file = f"{course_name}_attendance_{date}.csv"

	try:
		with open(output_file, mode='w', newline='') as file:
			writer = csv.writer(file)

			writer.writerow(["Student Name", "Matricule", "Attendance"])

			for student, matricule in zip(students, matricules):
				attendance = gen_rand_att()

				writer.writerow([student, matricule, attendance])

		print(f"Random attendance data saved to {output_file}")

	except Exception as e:
		print(f"An error occurred:{e}")

if __name__ == "__main__":
	main()

