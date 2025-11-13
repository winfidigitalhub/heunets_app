import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';
import '../bloc/applied_jobs_bloc.dart';
import '../bloc/applied_jobs_event.dart';
import '../bloc/applied_jobs_state.dart';
import '../../../jobs/data/model/job_model.dart';
import '../../../jobs/presentation/widget/jobs_widgets.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  @override
  void initState() {
    super.initState();
    // Load applied jobs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppliedJobsBloc>().add(const LoadAppliedJobsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade50,
        title: const Text('Applied Jobs'),
      ),
      body: BlocBuilder<AppliedJobsBloc, AppliedJobsState>(
        builder: (context, state) {
          if (state is AppliedJobsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade900,
                strokeWidth: 3,
              ),
            );
          } else if (state is AppliedJobsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AppliedJobsEmpty) {
            return const Center(child: Text('You have not applied to any jobs yet'));
          } else if (state is AppliedJobsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                Job job = state.jobs[index];
                return JobCard(job: job);
              },
            );
          }
          return const Center(child: Text('You have not applied to any jobs yet'));
        },
      ),
      bottomNavigationBar: const GlobalBottomNavBar(),
    );
  }
}

