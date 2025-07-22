import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/user.png'),
              ),
              SizedBox(height: 16),
              Text(
                'Exodus Trivellan',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                'Product Manager',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('28', 'Applied'),
                  _buildStatCard('78', 'Reviewed'),
                  _buildStatCard('16', 'Contacted'),
                ],
              ),
              SizedBox(height: 16),
              _buildProfileCompletionCard(),
              SizedBox(height: 16),
              ListTile(
                title: Text('Account Setting',
                    style: TextStyle(color: Colors.black)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  // Hesap ayarları işlemi
                },
              ),
              Divider(),
              ListTile(
                title: Text('Get Pro', style: TextStyle(color: Colors.black)),
                subtitle: Text('Buy Pro Account ',
                    style: TextStyle(color: Colors.grey[700])),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () {
                    // Pro satın alma işlemi
                  },
                  child: Text('Buy Now', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete Profile',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCompletionStepCard(
                'Education', '03 Steps Left', Colors.grey[400]!),
            _buildCompletionStepCard(
                'Professional', '03 Steps Left', Colors.grey[500]!),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionStepCard(String title, String steps, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            steps,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
