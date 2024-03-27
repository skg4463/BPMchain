pragma solidity ^0.8.0;

// WorkItemContract 정의
contract WorkItemContract {
    // 대출 신청에 대한 정보를 담는 구조체
    struct LoanApplication {
        address applicant; // 신청자 주소
        uint256 loanAmount; // 대출 금액
        string purpose; // 대출 목적
        // 추가정보
        // address IPFS-address::image.etc.
    }

    LoanApplication public loanApplication; // 대출 신청 정보
    address[] public approvers; // 승인자 목록
    uint256 public currentApproverIndex; // 현재 승인 단계
    bool public isApproved; // 승인 완료 여부

    // 승인자만 접근할 수 있도록 하는 수정자
    modifier onlyApprover() {
        require(
            msg.sender == approvers[currentApproverIndex],
            "Not an authorized approver."
        );
        _;
    }

    // 승인 과정을 나타내는 이벤트
    event ReviewStarted(address approver);
    event Approved(address approver);

    // 생성자
    constructor(
        address _applicant,
        uint256 _loanAmount,
        string memory _purpose,
        address[] memory _approvers
    ) {
        loanApplication = LoanApplication(_applicant, _loanAmount, _purpose);
        approvers = _approvers;
        currentApproverIndex = 0;
        isApproved = false;
    }

    // 다음 승인 단계로 이동하는 함수
    function nextStep() public onlyApprover {
        currentApproverIndex++;
        if (currentApproverIndex < approvers.length) {
            emit ReviewStarted(approvers[currentApproverIndex]);
        } else {
            isApproved = true;
            emit Approved(msg.sender);
        }
    }
}

// WorkItemApplicationContract 정의
contract WorkItemApplicationContract {
    address[] public workItems; // 생성된 WorkItemContract 주소 목록

    event WorkItemCreated(address indexed workItemAddress); // 작업 생성 이벤트

    // 새 WorkItemContract 생성 함수
    function createWorkItem(
        address _applicant,
        uint256 _loanAmount,
        string memory _purpose,
        address[] memory _approvers
    ) public {
        WorkItemContract newWorkItem = new WorkItemContract(
            _applicant,
            _loanAmount,
            _purpose,
            _approvers
        );
        workItems.push(address(newWorkItem));
        emit WorkItemCreated(address(newWorkItem));
    }

    // 생성된 WorkItemContract 목록 반환 함수
    function getWorkItems() public view returns (address[] memory) {
        return workItems;
    }
}
