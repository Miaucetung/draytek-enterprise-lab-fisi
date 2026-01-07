#!/usr/bin/env python3
"""
IHK Exam Quiz - Interactive Question Practice
Author: DrayTek Enterprise Lab
Version: 1.0
"""

import random
import sys
import argparse
from typing import List, Dict

# Sample questions (würde aus exam-questions.md geparst werden)
QUESTIONS = [
    {
        "id": 1,
        "category": "VLAN",
        "difficulty": "easy",
        "question": "Was ist der Hauptzweck von VLANs?",
        "options": {
            "A": "Erhöhung der physischen Bandbreite",
            "B":  "Logische Segmentierung eines Netzwerks",
            "C": "Verschlüsselung von Datenverkehr",
            "D": "Automatische IP-Adressvergabe"
        },
        "answer": "B",
        "explanation": "VLANs ermöglichen logische Segmentierung."
    },
    {
        "id": 2,
        "category": "Firewall",
        "difficulty": "medium",
        "question": "Was bedeutet Default-Deny-Policy?",
        "options": {
            "A": "Alle Verbindungen erlaubt",
            "B": "Nur HTTPS erlaubt",
            "C":  "Alle Verbindungen blockiert",
            "D": "Nur lokaler Traffic erlaubt"
        },
        "answer": "C",
        "explanation": "Default-Deny = Least-Privilege-Prinzip."
    },
    # ...  weitere Fragen
]

class ExamQuiz:
    def __init__(self, questions: List[Dict], count: int = 10, random_order: bool = True):
        self.questions = questions
        self. count = min(count, len(questions))
        self.random_order = random_order
        self.score = 0
        self.total = 0
        
    def run(self):
        print("=" * 60)
        print("  IHK PRÜFUNGSVORBEREITUNG - QUIZ")
        print("=" * 60)
        print()
        
        selected = random.sample(self.questions, self.count) if self.random_order else self.questions[: self.count]
        
        for i, q in enumerate(selected, 1):
            self.ask_question(i, q)
        
        self.show_results()
    
    def ask_question(self, num: int, question: Dict):
        print(f"\n{'='*60}")
        print(f"Frage {num}/{self.count} [{question['difficulty']. upper()}]")
        print(f"Kategorie: {question['category']}")
        print(f"{'='*60}\n")
        print(question['question'])
        print()
        
        for key, value in sorted(question['options'].items()):
            print(f"  {key}) {value}")
        
        print()
        answer = input("Deine Antwort (A/B/C/D): ").strip().upper()
        
        self.total += 1
        if answer == question['answer']:
            self.score += 1
            print("\n✅ RICHTIG!")
        else:
            print(f"\n❌ FALSCH! Richtige Antwort: {question['answer']}")
        
        print(f"\n💡 Erklärung: {question['explanation']}")
        input("\nDrücke Enter für nächste Frage...")
    
    def show_results(self):
        percentage = (self.score / self. total * 100) if self.total > 0 else 0
        
        print("\n" + "=" * 60)
        print("  ENDERGEBNIS")
        print("=" * 60)
        print(f"\nRichtige Antworten: {self.score} / {self.total}")
        print(f"Prozent: {percentage:.1f}%")
        
        if percentage >= 90:
            print("\n🏆 EXZELLENT!  Du bist bestens vorbereitet!")
        elif percentage >= 70:
            print("\n✅ GUT! Mit etwas mehr Übung bist du perfekt vorbereitet.")
        elif percentage >= 50:
            print("\n⚠️  BESTANDEN, aber Luft nach oben.  Weiter üben!")
        else:
            print("\n❌ NICHT BESTANDEN. Wiederhole die Labs und versuche es erneut.")

def main():
    parser = argparse.ArgumentParser(description="IHK Exam Quiz")
    parser.add_argument("--count", type=int, default=10, help="Number of questions")
    parser.add_argument("--category", type=str, help="Filter by category")
    parser.add_argument("--difficulty", type=str, choices=["easy", "medium", "hard"], help="Filter by difficulty")
    parser.add_argument("--random", action="store_true", help="Random order")
    
    args = parser.parse_args()
    
    questions = QUESTIONS
    
    if args.category:
        questions = [q for q in questions if q['category']. lower() == args.category.lower()]
    
    if args.difficulty:
        questions = [q for q in questions if q['difficulty'] == args.difficulty]
    
    if not questions:
        print("Keine Fragen gefunden für die gewählten Filter.")
        sys.exit(1)
    
    quiz = ExamQuiz(questions, count=args.count, random_order=args.random)
    quiz.run()

if __name__ == "__main__": 
    main()