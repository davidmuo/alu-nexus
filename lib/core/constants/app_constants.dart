class AppConstants {
  AppConstants._();

  static const String appName = 'ALU Nexus';
  static const String appTagline = 'Connect. Build. Grow.';

  // ALU email domain for validation
  static const String aluStudentDomain = '@alustudent.com';
  static const String aluFacultyDomain = '@alueducation.com';
  static const List<String> aluDomains = [aluStudentDomain, aluFacultyDomain];

  // User roles
  static const String roleStudent = 'student';
  static const String roleStartup = 'startup';
  static const String roleAdmin = 'admin';

  // Startup verification statuses
  static const String verificationPending = 'pending';
  static const String verificationApproved = 'approved';
  static const String verificationRejected = 'rejected';

  // Application statuses
  static const String appStatusPending = 'pending';
  static const String appStatusReviewing = 'reviewing';
  static const String appStatusShortlisted = 'shortlisted';
  static const String appStatusInterviewing = 'interviewing';
  static const String appStatusAccepted = 'accepted';
  static const String appStatusRejected = 'rejected';
  static const String appStatusWithdrawn = 'withdrawn';

  // Opportunity types
  static const List<String> opportunityTypes = [
    'Software Development',
    'UI/UX Design',
    'Marketing',
    'Business Development',
    'Operations',
    'Research & Analysis',
    'Content Creation',
    'Community Management',
    'Finance',
    'Sales',
    'Product Management',
    'Data Science',
  ];

  // Duration options
  static const List<String> durationOptions = [
    '1 month', '2 months', '3 months', '4 months', '6 months', 'Ongoing',
  ];

  // Commitment options
  static const List<String> commitmentOptions = [
    'Full-time', 'Part-time', 'Flexible', 'Remote', 'On-site', 'Hybrid',
  ];

  // ALU cohort programs
  static const List<String> aluPrograms = [
    'BSc Computer Science',
    'BSc Electrical Engineering',
    'BSc Applied Mathematics and Computer Science',
    'BSc Mechatronics Engineering',
    'BSc Global Challenges',
    'BSc Business and Entrepreneurship',
    'BSc Data Science and Artificial Intelligence',
  ];

  // Skills list for matching
  static const List<String> allSkills = [
    'Flutter', 'React', 'Node.js', 'Python', 'JavaScript', 'TypeScript',
    'Firebase', 'PostgreSQL', 'MongoDB', 'AWS', 'Figma', 'Adobe XD',
    'Photoshop', 'Illustrator', 'Video Editing', 'Copywriting', 'SEO',
    'Social Media', 'Email Marketing', 'Market Research', 'Data Analysis',
    'Excel', 'SQL', 'Tableau', 'PowerPoint', 'Project Management',
    'Agile / Scrum', 'Customer Service', 'Sales', 'Public Speaking',
    'Finance', 'Accounting', 'Legal Research', 'Machine Learning',
    'Computer Vision', 'NLP', 'Django', 'FastAPI', 'Swift', 'Kotlin',
    'Unity', 'AR/VR', 'Blockchain', 'Web3', '3D Design', 'AutoCAD',
  ];
}
