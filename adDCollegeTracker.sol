// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.5.0;

contract adDecentralizedCollegeTracker {
    address universityAdmin;

    constructor() {
        /*
         * universityAdmin  :   One who will deploy this smart contract.
         * 
        */
        universityAdmin = msg.sender;
    }

    /* Modifier Name: onlyUniversityAdmin
     * 
     * Description: Restrict access to University admin ONLY.
     *
    */
    modifier onlyUniversityAdmin() {
        require(msg.sender == universityAdmin, "Only university admin can access");
        _;
    }


    struct College {
        address CollegeAddress;
        address CollegeAdminAddress;
        string CollegeName;
        uint256 CollegeRegistrationNumber;
        uint256 NoOfStudents;
        bool CanAddStudent;
    }

    struct Student {
        address CollegeAddress;
        address StudentAddress;
        string StudentName;
        uint256 StudentPhoneNumber;
        string CourseEnrolled; 
    }

    mapping(address => College) Colleges;
    mapping(address => uint) CollegeAdmins;
    mapping(address => Student) Students;


    /* Function Name: isAssigned
     *
     * Description: This function will check given ethereum address exist in the system or not.
     *
     * parameters:
     * _ethAddress  :   address :   Ethereum address to be checked
     *
     * return:
     * bool         :   True if exist, False if not
     *
    */
    function isAssigned(address _ethAddress) private view returns(bool) {
        if(
            // check if given address is of university admin?
            _ethAddress == universityAdmin ||
            
            // check if given address is of any existing college?
            Colleges[_ethAddress].CollegeRegistrationNumber != 0 ||

            // check if given address is of any existing college admin?
            CollegeAdmins[_ethAddress] != 0 ||

            // check if given address is of any existing student?
            Students[_ethAddress].StudentPhoneNumber != 0
        ) { return true; }

        return false;
    }

    function areBothStringsSame(string memory a, string memory b) private pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        }
        else {
            return keccak256(bytes(a)) == keccak256(bytes(b));
        }
    }


    /*
     * Function Name: addNewCollege
     * 
     * Description: 
     * This function is used by the university admin to add a new college.
     * This function can be called by admin only.
     * 
     * parameters:
     * _collegeName             :   string  :   The name of the college
     * _collegeEthAddress       :   address :   The unique Ethereum address of the college
     * _collegeAdminEthAddress  :   address :   The unique Ethereum address of the college admin
     * _collegeRegNo            :   string  :   College registration number
     *
    */
    function addNewCollege(
        string memory _collegeName,
        address _collegeEthAddress,
        address _collegeAdminEthAddress,
        uint256 _collegeRegNo
        ) onlyUniversityAdmin public {
        require(!isAssigned(_collegeEthAddress), "Can't assign given address to this new college, ALREADY TAKEN.");
        require(!isAssigned(_collegeAdminEthAddress), "Can't assign given address to this new college admin, ALREADY TAKEN.");
 
        Colleges[_collegeEthAddress] = College(
                                            _collegeEthAddress, 
                                            _collegeAdminEthAddress, 
                                            _collegeName, 
                                            _collegeRegNo, 0, true
                                        );

        CollegeAdmins[_collegeAdminEthAddress] = _collegeRegNo;
    }

    /*
     * Function Name: viewCollegeDetails
     * 
     * Description: This function is used to view college details.
     * 
     * parameters:
     * _collegeEthAddress   :   address :   The unique Ethereum address of the college
     * 
     * returns:
     * string   :   The name of the college
     * string   :   The registration number of the college
     * uint256  :   Number of students in that college
     *
    */
    function viewCollegeDetails(address _collegeEthAddress) onlyUniversityAdmin public view 
    returns(address, string memory, uint256, uint256, bool) {
       //require(isExist(_collegeEthAddress), "College with given address DOES NOT EXIST"); 
       return (
            Colleges[_collegeEthAddress].CollegeAdminAddress,
            Colleges[_collegeEthAddress].CollegeName,
            Colleges[_collegeEthAddress].CollegeRegistrationNumber,
            Colleges[_collegeEthAddress].NoOfStudents,
            Colleges[_collegeEthAddress].CanAddStudent
        );
    }

    /*
     * Function Name: viewCollegeAdminDetail
     * 
     * Description: This function is used to view college admin details.
     * 
     * parameters:
     * _collegeAdminEthAddress   :   address :   The unique Ethereum address of the college
     * 
     * returns:
     * uint256  :   Registration Number of associated college
     *
    */
    function viewCollegeAdminDetail(address _collegeAdminEthAddress) onlyUniversityAdmin public view returns(uint256) {
       return CollegeAdmins[_collegeAdminEthAddress];
    }

    /*
     * Function Name: getNumberOfStudents
     * 
     * Description: This function is used to view number of students in a college.
     * 
     * parameters:
     * _collegeEthAddress   :   address :   The unique Ethereum address of the college
     * 
     * returns:
     * uint256  :   Number of students in that college
     *
    */
    function getNumberOfStudents(address _collegeEthAddress) public view returns(uint256) {
       //require(isExist(_collegeEthAddress), "College with given address DOES NOT EXIST");
       return Colleges[_collegeEthAddress].NoOfStudents;
    }

    /*
     * Function Name: blockCollegeToAddNewStudents
     * 
     * Description: This function is used by the university admin to block colleges from adding any new students.
     * 
     * parameters:
     * _collegeEthAddress   :   address :   The unique Ethereum address of the college
     *
    */
    function blockCollegeToAddNewStudents(address _collegeEthAddress) onlyUniversityAdmin public {
        //require(isExist(_collegeEthAddress), "College with given address DOES NOT EXIST");
        Colleges[_collegeEthAddress].CanAddStudent = false;
    }

    /*
     * Function Name: unblockCollegeToAddNewStudents
     * 
     * Description: This function is used by the university admin to block colleges from adding any new students.
     * 
     * parameters:
     * _collegeEthAddress   :   address :   The unique Ethereum address of the college
     *
    */
    function unblockCollegeToAddNewStudents(address _collegeEthAddress) onlyUniversityAdmin public {
        //require(isExist(_collegeEthAddress), "College with given address DOES NOT EXIST");
        Colleges[_collegeEthAddress].CanAddStudent = true;
    }

    /*
     * Function Name: addNewStudent
     * 
     * Description: This function will add a student to the college.
     * 
     * parameters:
     * _collegeEthAddress   :   address :   The unique Ethereum address of the college
     * _studentName         :   string  :   The name of the student
     * _phoneNumber         :   uint    :   The phone number of the student
     * _courseName          :   string  :   The name of the course
     *
    */
    function addNewStudent(
        address _collegeEthAddress,
        address _studentEthAddress,
        string memory _studentName,
        uint256 _phoneNumber,
        string memory _courseName
        ) onlyUniversityAdmin public {
        require(isAssigned(_collegeEthAddress), "College with given address DOES NOT EXIST");
        require(!isAssigned(_studentEthAddress), "Can't assign given address to this new student, ALREADY TAKEN.");
        require(Colleges[_collegeEthAddress].CanAddStudent, "Currently college is not allowed to add new students.");
        
        Students[_studentEthAddress] = Student(
                                                _collegeEthAddress, 
                                                _studentEthAddress,
                                                 _studentName, 
                                                 _phoneNumber, 
                                                 _courseName
                                        );
        
        Colleges[_collegeEthAddress].NoOfStudents++;
    }

    /*
     * Function Name: viewStudentDetails
     * 
     * Description: This function is used to view student details.
     * 
     * parameters:
     * _studentEthAddress   :   address :   The unique Ethereum address of the student
     * 
     * returns:
     * string   :   The name of the student
     * uint256  :   The phone number of the student
     * string   :   College Name of the student
     * string   :   Course Enrolled by the student
     *
    */
    function viewStudentDetails(address _studentEthAddress) public view 
    returns(string memory, uint256, string memory, string memory) {
        require(msg.sender == Colleges[Students[_studentEthAddress].CollegeAddress].CollegeAdminAddress, "This feature is only availabe for College Admin ONLY.");
        return (
            Students[_studentEthAddress].StudentName,
            Students[_studentEthAddress].StudentPhoneNumber,
            Colleges[Students[_studentEthAddress].CollegeAddress].CollegeName,
            Students[_studentEthAddress].CourseEnrolled
        );
    }

    /*
     * Function Name: changeStudentCourse
     * 
     * Description: This function is used by college admin to change a student's course.
     * 
     * parameters:
     * _collegeEthAddress   :   address :   The unique Ethereum address of the college
     * _collegeEthAddress   :   address :   The unique Ethereum address of the student
     * _newCourseName       :   string  :   The name of the new course
     *
    */
    function changeStudentCourse(
        address _collegeEthAddress,
        address _studentEthAddress,
        string memory _newCourseName
        ) public {
        require(Students[_studentEthAddress].CollegeAddress == _collegeEthAddress, "This student is not from your college.");
        require(msg.sender == Colleges[Students[_studentEthAddress].CollegeAddress].CollegeAdminAddress, "This feature is only availabe for College Admin ONLY.");
        require(!areBothStringsSame(Students[_studentEthAddress].CourseEnrolled, _newCourseName), "Student already enrolled in this course");
        
        Students[_studentEthAddress].CourseEnrolled = _newCourseName;
    }
}

// University Admin: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

// KIT (college): 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// KIT ADMIN: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// ADITYA (student): 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
// JAIN (student): 0x617F2E2fD72FD9D5503197092aC168c91465E7f2

// MIT: 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
// MIT ADMIN: 0x583031D1113aD414F02576BD6afaBfb302140225


