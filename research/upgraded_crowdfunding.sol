// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    event CampaignCreated(
        uint256 campaignId,
        address owner,
        string title,
        string description,
        uint256 target,
        uint256 deadline,
        string image
    );

    event Donated(uint256 campaignId, address donor, uint256 amount);

    event AmountUpdated(uint256 campaignId, uint256 amountCollected);

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        // calidate due date
        require(
            _deadline > block.timestamp,
            "The deadline should be in future"
        );

        Campaign storage campaign = campaigns[numberOfCampaigns];

        // create new campaign
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        // campaigns number increment
        numberOfCampaigns++;

        // call events
        emit CampaignCreated(
            numberOfCampaigns - 1,
            _owner,
            _title,
            _description,
            _target,
            _deadline,
            _image
        );

        // return index
        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        Campaign storage campaign = campaigns[_id];

        campaign.amountCollected += msg.value;

        campaign.donators.push(msg.sender);
        campaign.donations.push(msg.value);

        emit Donated(_id, msg.sender, msg.value);

        emit AmountUpdated(_id, campaign.amountCollected);

        (bool sent, ) = payable(campaign.owner).call{value: msg.value}("");

        require(sent, "Transaction failed");
    }

    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }
        return allCampaigns;
    }
}
